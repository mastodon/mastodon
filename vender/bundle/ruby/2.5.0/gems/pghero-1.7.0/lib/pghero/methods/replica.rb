module PgHero
  module Methods
    module Replica
      def replica?
        unless defined?(@replica)
          @replica = PgHero.truthy?(select_all("SELECT pg_is_in_recovery()").first["pg_is_in_recovery"])
        end
        @replica
      end

      # http://www.postgresql.org/message-id/CADKbJJWz9M0swPT3oqe8f9+tfD4-F54uE6Xtkh4nERpVsQnjnw@mail.gmail.com
      def replication_lag
        select_all(<<-SQL
          SELECT
            CASE
              WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0
              ELSE EXTRACT (EPOCH FROM NOW() - pg_last_xact_replay_timestamp())
            END
          AS replication_lag
        SQL
        ).first["replication_lag"].to_f
      end
    end
  end
end
