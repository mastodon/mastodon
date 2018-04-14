module PgHero
  module Methods
    module Space
      def database_size
        select_all("SELECT pg_size_pretty(pg_database_size(current_database()))").first["pg_size_pretty"]
      end

      def relation_sizes
        select_all <<-SQL
          SELECT
            n.nspname AS schema,
            c.relname AS name,
            CASE WHEN c.relkind = 'r' THEN 'table' ELSE 'index' END AS type,
            pg_size_pretty(pg_table_size(c.oid)) AS size,
            pg_table_size(c.oid) AS size_bytes
          FROM
            pg_class c
          LEFT JOIN
            pg_namespace n ON (n.oid = c.relnamespace)
          WHERE
            n.nspname NOT IN ('pg_catalog', 'information_schema')
            AND n.nspname !~ '^pg_toast'
            AND c.relkind IN ('r', 'i')
          ORDER BY
            pg_table_size(c.oid) DESC,
            name ASC
        SQL
      end

      def capture_space_stats
        now = Time.now
        columns = %w[database schema relation size captured_at]
        values = []
        relation_sizes.each do |rs|
          values << [id, rs["schema"], rs["name"], rs["size_bytes"].to_i, now]
        end
        insert_stats("pghero_space_stats", columns, values)
      end
    end
  end
end
