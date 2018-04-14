module PgHero
  module Methods
    module Queries
      def running_queries(options = {})
        min_duration = options[:min_duration]
        select_all <<-SQL
          SELECT
            pid,
            state,
            application_name AS source,
            age(NOW(), COALESCE(query_start, xact_start)) AS duration,
            #{server_version_num >= 90600 ? "(wait_event IS NOT NULL) AS waiting" : "waiting"},
            query,
            COALESCE(query_start, xact_start) AS started_at,
            EXTRACT(EPOCH FROM NOW() - COALESCE(query_start, xact_start)) * 1000.0 AS duration_ms,
            usename AS user
          FROM
            pg_stat_activity
          WHERE
            query <> '<insufficient privilege>'
            AND state <> 'idle'
            AND pid <> pg_backend_pid()
            AND datname = current_database()
            #{min_duration ? "AND NOW() - COALESCE(query_start, xact_start) > interval '#{min_duration.to_i} seconds'" : nil}
          ORDER BY
            COALESCE(query_start, xact_start) DESC
        SQL
      end

      def long_running_queries
        running_queries(min_duration: long_running_query_sec)
      end

      def locks
        select_all <<-SQL
          SELECT DISTINCT ON (pid)
            pg_stat_activity.pid,
            pg_stat_activity.query,
            age(now(), pg_stat_activity.query_start) AS age
          FROM
            pg_stat_activity
          INNER JOIN
            pg_locks ON pg_locks.pid = pg_stat_activity.pid
          WHERE
            pg_stat_activity.query <> '<insufficient privilege>'
            AND pg_locks.mode = 'ExclusiveLock'
            AND pg_stat_activity.pid <> pg_backend_pid()
            AND pg_stat_activity.datname = current_database()
          ORDER BY
            pid,
            query_start
        SQL
      end

      # from https://wiki.postgresql.org/wiki/Lock_Monitoring
      # and http://big-elephants.com/2013-09/exploring-query-locks-in-postgres/
      def blocked_queries
        select_all <<-SQL
          SELECT
            COALESCE(blockingl.relation::regclass::text,blockingl.locktype) as locked_item,
            blockeda.pid AS blocked_pid,
            blockeda.usename AS blocked_user,
            blockeda.query as blocked_query,
            age(now(), blockeda.query_start) AS blocked_duration,
            blockedl.mode as blocked_mode,
            blockinga.pid AS blocking_pid,
            blockinga.usename AS blocking_user,
            blockinga.state AS state_of_blocking_process,
            blockinga.query AS current_or_recent_query_in_blocking_process,
            age(now(), blockinga.query_start) AS blocking_duration,
            blockingl.mode as blocking_mode
          FROM
            pg_catalog.pg_locks blockedl
          LEFT JOIN
            pg_stat_activity blockeda ON blockedl.pid = blockeda.pid
          LEFT JOIN
            pg_catalog.pg_locks blockingl ON blockedl.pid != blockingl.pid AND (
              blockingl.transactionid = blockedl.transactionid
              OR (blockingl.relation = blockedl.relation AND blockingl.locktype = blockedl.locktype)
            )
          LEFT JOIN
            pg_stat_activity blockinga ON blockingl.pid = blockinga.pid AND blockinga.datid = blockeda.datid
          WHERE
            NOT blockedl.granted
            AND blockeda.query <> '<insufficient privilege>'
            AND blockeda.datname = current_database()
          ORDER BY
            blocked_duration DESC
        SQL
      end
    end
  end
end
