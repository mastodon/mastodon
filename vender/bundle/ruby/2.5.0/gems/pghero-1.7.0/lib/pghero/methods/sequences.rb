module PgHero
  module Methods
    module Sequences
      def sequences
        sequences = select_all <<-SQL
          SELECT
            sequence_schema AS schema,
            table_name AS table,
            column_name AS column,
            c.data_type AS column_type,
            CASE WHEN c.data_type = 'integer' THEN 2147483647::bigint ELSE maximum_value::bigint END AS max_value,
            sequence_name AS sequence
          FROM
            information_schema.columns c
          INNER JOIN
            information_schema.sequences iss ON iss.sequence_name = regexp_replace(c.column_default, '^nextval\\(''(.*)''\\:\\:regclass\\)$', '\\1')
          WHERE
            column_default LIKE 'nextval%'
            AND table_catalog = current_database()
          ORDER BY
            sequence_name ASC
        SQL

        select_all(sequences.map { |s| "SELECT last_value FROM #{s["sequence"]}" }.join(" UNION ALL ")).each_with_index do |row, i|
          sequences[i]["last_value"] = row["last_value"]
        end

        sequences
      end

      def sequence_danger(options = {})
        threshold = (options[:threshold] || 0.9).to_f
        sequences.select { |s| s["last_value"].to_i / s["max_value"].to_f > threshold }.sort_by { |s| s["max_value"].to_i - s["last_value"].to_i }
      end
    end
  end
end
