require "concurrent"

module NSA
  module Statsd
    module AsyncPublisher
      include ::NSA::Statsd::Publisher

      def async_statsd_count(key, sample_rate = 1, &block)
        return unless sample_rate == 1 || rand < sample_rate

        ::Concurrent::Promise.execute(&block).then do |value|
          statsd_count(key, value)
        end
      end

      def async_statsd_gauge(key, sample_rate = 1, &block)
        return unless sample_rate == 1 || rand < sample_rate

        ::Concurrent::Promise.execute(&block).then do |value|
          statsd_gauge(key, value)
        end
      end

      def async_statsd_set(key, sample_rate = 1, &block)
        return unless sample_rate == 1 || rand < sample_rate

        ::Concurrent::Promise.execute(&block).then do |value|
          statsd_set(key, value)
        end
      end

      def async_statsd_time(key, sample_rate = 1, &block)
        return unless sample_rate == 1 || rand < sample_rate

        ::Concurrent::Future.execute do
          statsd_time(key, &block)
        end
      end

      def async_statsd_timing(key, sample_rate = 1, &block)
        return unless sample_rate == 1 || rand < sample_rate

        ::Concurrent::Promise.execute(&block).then do |value|
          statsd_timing(key, value)
        end
      end

    end
  end
end
