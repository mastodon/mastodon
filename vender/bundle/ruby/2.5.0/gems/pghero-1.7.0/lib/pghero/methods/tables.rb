module PgHero
  module Methods
    module Tables
      def table_hit_rate
        select_all(<<-SQL
          SELECT
            sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read), 0) AS rate
          FROM
            pg_statio_user_tables
        SQL
        ).first["rate"].to_f
      end

      def table_caching
        select_all <<-SQL
          SELECT
            relname AS table,
            CASE WHEN heap_blks_hit + heap_blks_read = 0 THEN
              0
            ELSE
              ROUND(1.0 * heap_blks_hit / (heap_blks_hit + heap_blks_read), 2)
            END AS hit_rate
          FROM
            pg_statio_user_tables
          ORDER BY
            2 DESC, 1
        SQL
      end

      def unused_tables
        select_all <<-SQL
          SELECT
            schemaname AS schema,
            relname AS table,
            n_live_tup rows_in_table
          FROM
            pg_stat_user_tables
          WHERE
            idx_scan = 0
          ORDER BY
            n_live_tup DESC,
            relname ASC
         SQL
      end

      def table_stats(options = {})
        schema = options[:schema]
        tables = options[:table] ? Array(options[:table]) : nil
        select_all <<-SQL
          SELECT
            nspname AS schema,
            relname AS table,
            reltuples::bigint
          FROM
            pg_class
          INNER JOIN
            pg_namespace ON pg_namespace.oid = pg_class.relnamespace
          WHERE
            relkind = 'r'
            #{schema ? "AND nspname = #{quote(schema)}" : nil}
            #{tables ? "AND relname IN (#{tables.map { |t| quote(t) }.join(", ")})" : nil}
          ORDER BY
            1, 2
        SQL
      end
    end
  end
end
