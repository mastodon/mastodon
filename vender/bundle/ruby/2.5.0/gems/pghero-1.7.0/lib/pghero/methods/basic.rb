module PgHero
  module Methods
    module Basic
      def settings
        names =
          if server_version_num >= 90500
            %w(
              max_connections shared_buffers effective_cache_size work_mem
              maintenance_work_mem min_wal_size max_wal_size checkpoint_completion_target
              wal_buffers default_statistics_target
            )
          else
            %w(
              max_connections shared_buffers effective_cache_size work_mem
              maintenance_work_mem checkpoint_segments checkpoint_completion_target
              wal_buffers default_statistics_target
            )
          end
        Hash[names.map { |name| [name, select_all("SHOW #{name}").first[name]] }]
      end

      def ssl_used?
        ssl_used = nil
        connection_model.transaction do
          execute("CREATE EXTENSION IF NOT EXISTS sslinfo")
          ssl_used = PgHero.truthy?(select_all("SELECT ssl_is_used()").first["ssl_is_used"])
          raise ActiveRecord::Rollback
        end
        ssl_used
      end

      def database_name
        select_all("SELECT current_database()").first["current_database"]
      end

      def server_version
        select_all("SHOW server_version").first["server_version"]
      end

      private

      def select_all(sql)
        # squish for logs
        connection.select_all(squish(sql)).to_a
      end

      def execute(sql)
        connection.execute(sql)
      end

      def connection
        connection_model.connection
      end

      # from ActiveSupport
      def squish(str)
        str.to_s.gsub(/\A[[:space:]]+/, "").gsub(/[[:space:]]+\z/, "").gsub(/[[:space:]]+/, " ")
      end

      def quote(value)
        connection.quote(value)
      end

      def quote_table_name(value)
        connection.quote_table_name(value)
      end

      def unquote(part)
        if part && part.start_with?('"')
          part[1..-2]
        else
          part
        end
      end

      def with_lock_timeout(timeout)
        connection_model.transaction do
          select_all "SET LOCAL lock_timeout = #{timeout.to_i}"
          yield
        end
      end
    end
  end
end
