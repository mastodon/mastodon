require "active_support/notifications"
require "nsa/statsd/publisher"

module NSA
  module Collectors
    module ActiveSupportCache
      extend ::NSA::Statsd::Publisher

      CACHE_TYPES = {
        "cache_delete.active_support" => :delete,
        "cache_exist?.active_support" => :exist?,
        "cache_fetch_hit.active_support" => :fetch_hit,
        "cache_generate.active_support" => :generate,
        "cache_read.active_support" => :read,
        "cache_write.active_support" => :write,
      }.freeze

      def self.collect(key_prefix)
        ::ActiveSupport::Notifications.subscribe(/cache_[^.]+.active_support/) do |*event_args|
          event = ::ActiveSupport::Notifications::Event.new(*event_args)
          cache_type = CACHE_TYPES.fetch(event.name) do
            event.name.split(".").first.gsub(/^cache_/, "")
          end

          if cache_type == :read
            cache_type = event.payload[:hit] ? :read_hit : :read_miss
          end

          stat_name = "#{key_prefix}.#{cache_type}.duration"
          statsd_timing(stat_name, event.duration)
        end
      end

    end
  end
end

