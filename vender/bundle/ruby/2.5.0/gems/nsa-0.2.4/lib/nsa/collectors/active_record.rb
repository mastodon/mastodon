require "nsa/statsd/publisher"

module NSA
  module Collectors
    module ActiveRecord
      extend ::NSA::Statsd::Publisher

      # Ordered by most common query type
      MATCHERS = [
        [ :select, /^\s*SELECT.+?FROM\s+"?([^".\s),]+)"?/im ],
        [ :insert, /^\s*INSERT INTO\s+"?([^".\s]+)"?/im ],
        [ :update, /^\s*UPDATE\s+"?([^".\s]+)"?/im ],
        [ :delete, /^\s*DELETE.+FROM\s+"?([^".\s]+)"?/im ]
      ].freeze

      EMPTY_MATCH_RESULT = []

      def self.collect(key_prefix)
        ::ActiveSupport::Notifications.subscribe("sql.active_record") do |_, start, finish, _id, payload|
          query_type, table_name = match_query(payload[:sql])
          unless query_type.nil?
            stat_name = "#{key_prefix}.tables.#{table_name}.queries.#{query_type}.duration"
            duration_ms = (finish - start) * 1000
            statsd_timing(stat_name, duration_ms)
          end
        end
      end

      def self.match_query(sql)
        MATCHERS
          .lazy
          .map { |(type, regex)|
            match = (sql.match(regex) || EMPTY_MATCH_RESULT)
            [ type, match[1] ]
          }
          .detect { |(_, table_name)| ! table_name.nil? }
      end

    end
  end
end

