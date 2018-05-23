module PgHero
  module Methods
    module SuggestedIndexes
      def suggested_indexes_enabled?
        defined?(PgQuery) && query_stats_enabled?
      end

      # TODO clean this mess
      def suggested_indexes_by_query(options = {})
        best_indexes = {}

        if suggested_indexes_enabled?
          # get most time-consuming queries
          queries = options[:queries] || (options[:query_stats] || query_stats(historical: true, start_at: 24.hours.ago)).map { |qs| qs["query"] }

          # get best indexes for queries
          best_indexes = best_index_helper(queries)

          if best_indexes.any?
            existing_columns = Hash.new { |hash, key| hash[key] = Hash.new { |hash2, key2| hash2[key2] = [] } }
            indexes = self.indexes
            indexes.group_by { |g| g["using"] }.each do |group, inds|
              inds.each do |i|
                existing_columns[group][i["table"]] << i["columns"]
              end
            end
            indexes_by_table = indexes.group_by { |i| i["table"] }

            best_indexes.each do |_query, best_index|
              if best_index[:found]
                index = best_index[:index]
                best_index[:table_indexes] = indexes_by_table[index[:table]].to_a
                covering_index = existing_columns[index[:using] || "btree"][index[:table]].find { |e| index_covers?(e, index[:columns]) }
                if covering_index
                  best_index[:covering_index] = covering_index
                  best_index[:explanation] = "Covered by index on (#{covering_index.join(", ")})"
                end
              end
            end
          end
        end

        best_indexes
      end

      def suggested_indexes(options = {})
        indexes = []

        (options[:suggested_indexes_by_query] || suggested_indexes_by_query(options)).select { |_s, i| i[:found] && !i[:covering_index] }.group_by { |_s, i| i[:index] }.each do |index, group|
          details = {}
          group.map(&:second).each do |g|
            details = details.except(:index).deep_merge(g)
          end
          indexes << index.merge(queries: group.map(&:first), details: details)
        end

        indexes.sort_by { |i| [i[:table], i[:columns]] }
      end

      def autoindex(options = {})
        suggested_indexes.each do |index|
          p index
          if options[:create]
            connection.execute("CREATE INDEX CONCURRENTLY ON #{quote_table_name(index[:table])} (#{index[:columns].map { |c| quote_table_name(c) }.join(",")})")
          end
        end
      end

      def autoindex_all(options = {})
        config["databases"].keys.each do |database|
          with(database) do
            puts "Autoindexing #{database}..."
            autoindex(options)
          end
        end
      end

      def best_index(statement, _options = {})
        best_index_helper([statement])[statement]
      end

      private

      def best_index_helper(statements)
        indexes = {}

        # see if this is a query we understand and can use
        parts = {}
        statements.each do |statement|
          parts[statement] = best_index_structure(statement)
        end

        # get stats about columns for relevant tables
        tables = parts.values.map { |t| t[:table] }.uniq
        # TODO get schema from query structure, then try search path
        schema = connection_model.connection_config[:schema] || "public"
        if tables.any?
          row_stats = Hash[table_stats(table: tables, schema: schema).map { |i| [i["table"], i["reltuples"]] }]
          col_stats = column_stats(table: tables, schema: schema).group_by { |i| i["table"] }
        end

        # find best index based on query structure and column stats
        parts.each do |statement, structure|
          index = {found: false}

          if structure[:error]
            index[:explanation] = structure[:error]
          elsif structure[:table].start_with?("pg_")
            index[:explanation] = "System table"
          else
            index[:structure] = structure

            table = structure[:table]
            where = structure[:where].uniq
            sort = structure[:sort]

            total_rows = row_stats[table].to_i
            index[:rows] = total_rows

            ranks = Hash[col_stats[table].to_a.map { |r| [r["column"], r] }]
            columns = (where + sort).map { |c| c[:column] }.uniq

            if columns.any?
              if columns.all? { |c| ranks[c] }
                first_desc = sort.index { |c| c[:direction] == "desc" }
                sort = sort.first(first_desc + 1) if first_desc
                where = where.sort_by { |c| [row_estimates(ranks[c[:column]], total_rows, total_rows, c[:op]), c[:column]] } + sort

                index[:row_estimates] = Hash[where.map { |c| ["#{c[:column]} (#{c[:op] || "sort"})", row_estimates(ranks[c[:column]], total_rows, total_rows, c[:op]).round] }]

                # no index needed if less than 500 rows
                if total_rows >= 500

                  if ["~~", "~~*"].include?(where.first[:op])
                    index[:found] = true
                    index[:row_progression] = [total_rows, index[:row_estimates].values.first]
                    index[:index] = {table: table, columns: ["#{where.first[:column]} gist_trgm_ops"], using: "gist"}
                  else
                    # if most values are unique, no need to index others
                    rows_left = total_rows
                    final_where = []
                    prev_rows_left = [rows_left]
                    where.reject { |c| ["~~", "~~*"].include?(c[:op]) }.each do |c|
                      next if final_where.include?(c[:column])
                      final_where << c[:column]
                      rows_left = row_estimates(ranks[c[:column]], total_rows, rows_left, c[:op])
                      prev_rows_left << rows_left
                      if rows_left < 50 || final_where.size >= 2 || [">", ">=", "<", "<=", "~~", "~~*", "BETWEEN"].include?(c[:op])
                        break
                      end
                    end

                    index[:row_progression] = prev_rows_left.map(&:round)

                    # if the last indexes don't give us much, don't include
                    prev_rows_left.reverse!
                    (prev_rows_left.size - 1).times do |i|
                      if prev_rows_left[i] > prev_rows_left[i + 1] * 0.3
                        final_where.pop
                      else
                        break
                      end
                    end

                    if final_where.any?
                      index[:found] = true
                      index[:index] = {table: table, columns: final_where}
                    end
                  end
                else
                  index[:explanation] = "No index needed if less than 500 rows"
                end
              else
                index[:explanation] = "Stats not found"
              end
            else
              index[:explanation] = "No columns to index"
            end
          end

          indexes[statement] = index
        end

        indexes
      end

      def best_index_structure(statement)
        return {error: "Too large"} if statement.to_s.length > 10000

        begin
          parsed_statement = PgQuery.parse(statement)
          v2 = parsed_statement.respond_to?(:tree)
          tree = v2 ? parsed_statement.tree : parsed_statement.parsetree
        rescue PgQuery::ParseError
          return {error: "Parse error"}
        end
        return {error: "Unknown structure"} unless tree.size == 1

        tree = tree.first
        table = parse_table(tree) rescue nil
        unless table
          error =
            case tree.keys.first
            when "InsertStmt", "INSERT INTO"
              "INSERT statement"
            when "VariableSetStmt", "SET"
              "SET statement"
            when "SelectStmt"
              if (tree["SelectStmt"]["fromClause"].first["JoinExpr"] rescue false)
                "JOIN not supported yet"
              end
            when "SELECT"
              if (tree["SELECT"]["fromClause"].first["JOINEXPR"] rescue false)
                "JOIN not supported yet"
              end
            end
          return {error: error || "Unknown structure"}
        end

        select = tree.values.first
        where = (select["whereClause"] ? parse_where(select["whereClause"], v2) : []) rescue nil
        return {error: "Unknown structure"} unless where

        sort = (select["sortClause"] ? parse_sort(select["sortClause"], v2) : []) rescue []

        {table: table, where: where, sort: sort}
      end

      def index_covers?(indexed_columns, columns)
        indexed_columns.first(columns.size) == columns
      end

      # TODO better row estimation
      # http://www.postgresql.org/docs/current/static/row-estimation-examples.html
      def row_estimates(stats, total_rows, rows_left, op)
        case op
        when "null"
          rows_left * stats["null_frac"].to_f
        when "not_null"
          rows_left * (1 - stats["null_frac"].to_f)
        else
          rows_left *= (1 - stats["null_frac"].to_f)
          ret =
            if stats["n_distinct"].to_f == 0
              0
            elsif stats["n_distinct"].to_f < 0
              if total_rows > 0
                (-1 / stats["n_distinct"].to_f) * (rows_left / total_rows.to_f)
              else
                0
              end
            else
              rows_left / stats["n_distinct"].to_f
            end

          case op
          when ">", ">=", "<", "<=", "~~", "~~*", "BETWEEN"
            (rows_left + ret) / 10.0 # TODO better approximation
          when "<>"
            rows_left - ret
          else
            ret
          end
        end
      end

      def parse_table(tree)
        case tree.keys.first
        when "SelectStmt"
          tree["SelectStmt"]["fromClause"].first["RangeVar"]["relname"]
        when "DeleteStmt"
          tree["DeleteStmt"]["relation"]["RangeVar"]["relname"]
        when "UpdateStmt"
          tree["UpdateStmt"]["relation"]["RangeVar"]["relname"]
        when "SELECT"
          tree["SELECT"]["fromClause"].first["RANGEVAR"]["relname"]
        when "DELETE FROM"
          tree["DELETE FROM"]["relation"]["RANGEVAR"]["relname"]
        when "UPDATE"
          tree["UPDATE"]["relation"]["RANGEVAR"]["relname"]
        end
      end

      # TODO capture values
      def parse_where(tree, v2 = false)
        if v2
          aexpr = tree["A_Expr"]

          if tree["BoolExpr"]
            if tree["BoolExpr"]["boolop"] == 0
              tree["BoolExpr"]["args"].flat_map { |v| parse_where(v, v2) }
            else
              raise "Not Implemented"
            end
          elsif aexpr && ["=", "<>", ">", ">=", "<", "<=", "~~", "~~*", "BETWEEN"].include?(aexpr["name"].first["String"]["str"])
            [{column: aexpr["lexpr"]["ColumnRef"]["fields"].last["String"]["str"], op: aexpr["name"].first["String"]["str"]}]
          elsif tree["NullTest"]
            op = tree["NullTest"]["nulltesttype"] == 1 ? "not_null" : "null"
            [{column: tree["NullTest"]["arg"]["ColumnRef"]["fields"].last["String"]["str"], op: op}]
          else
            raise "Not Implemented"
          end
        else
          aexpr = tree["AEXPR"] || tree[nil]

          if tree["BOOLEXPR"]
            if tree["BOOLEXPR"]["boolop"] == 0
              tree["BOOLEXPR"]["args"].flat_map { |v| parse_where(v) }
            else
              raise "Not Implemented"
            end
          elsif tree["AEXPR AND"]
            left = parse_where(tree["AEXPR AND"]["lexpr"])
            right = parse_where(tree["AEXPR AND"]["rexpr"])
            if left && right
              left + right
            else
              raise "Not Implemented"
            end
          elsif aexpr && ["=", "<>", ">", ">=", "<", "<=", "~~", "~~*", "BETWEEN"].include?(aexpr["name"].first)
            [{column: aexpr["lexpr"]["COLUMNREF"]["fields"].last, op: aexpr["name"].first}]
          elsif tree["AEXPR IN"] && ["=", "<>"].include?(tree["AEXPR IN"]["name"].first)
            [{column: tree["AEXPR IN"]["lexpr"]["COLUMNREF"]["fields"].last, op: tree["AEXPR IN"]["name"].first}]
          elsif tree["NULLTEST"]
            op = tree["NULLTEST"]["nulltesttype"] == 1 ? "not_null" : "null"
            [{column: tree["NULLTEST"]["arg"]["COLUMNREF"]["fields"].last, op: op}]
          else
            raise "Not Implemented"
          end
        end
      end

      def parse_sort(sort_clause, v2)
        if v2
          sort_clause.map do |v|
            {
              column: v["SortBy"]["node"]["ColumnRef"]["fields"].last["String"]["str"],
              direction: v["SortBy"]["sortby_dir"] == 2 ? "desc" : "asc"
            }
          end
        else
          sort_clause.map do |v|
            {
              column: v["SORTBY"]["node"]["COLUMNREF"]["fields"].last,
              direction: v["SORTBY"]["sortby_dir"] == 2 ? "desc" : "asc"
            }
          end
        end
      end

      def column_stats(options = {})
        schema = options[:schema]
        tables = options[:table] ? Array(options[:table]) : nil
        select_all <<-SQL
          SELECT
            schemaname AS schema,
            tablename AS table,
            attname AS column,
            null_frac,
            n_distinct
          FROM
            pg_stats
          WHERE
        #{tables ? "tablename IN (#{tables.map { |t| quote(t) }.join(", ")})" : "1 = 1"}
            AND schemaname = #{quote(schema)}
          ORDER BY
            1, 2, 3
        SQL
      end
    end
  end
end
