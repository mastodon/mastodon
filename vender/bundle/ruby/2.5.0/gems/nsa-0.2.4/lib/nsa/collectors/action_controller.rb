require "active_support/notifications"
require "nsa/statsd/publisher"

module NSA
  module Collectors
    module ActionController
      extend ::NSA::Statsd::Publisher

      def self.collect(key_prefix)
        ::ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
          event = ::ActiveSupport::Notifications::Event.new(*args)
          controller = event.payload[:controller]
          action = event.payload[:action]
          format = event.payload[:format] || "all"
          format = "all" if format == "*/*"
          status = event.payload[:status]
          key = "#{key_prefix}.#{controller}.#{action}.#{format}"

          statsd_timing("#{key}.total_duration", event.duration)
          statsd_timing("#{key}.db_time", event.payload[:db_runtime])
          statsd_timing("#{key}.view_time", event.payload[:view_runtime])
          statsd_increment("#{key}.status.#{status}")
        end
      end

    end
  end
end

