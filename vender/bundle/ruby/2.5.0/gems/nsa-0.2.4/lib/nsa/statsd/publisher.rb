module NSA
  module Statsd
    module Publisher

      def statsd_count(key, value = 1, sample_rate = nil)
        __statsd_publish(:count, key, value, sample_rate)
      end

      def statsd_decrement(key, sample_rate = nil)
        __statsd_publish(:decrement, key, 1, sample_rate)
      end

      def statsd_gauge(key, value = 1, sample_rate = nil)
        __statsd_publish(:gauge, key, value, sample_rate)
      end

      def statsd_increment(key, sample_rate = nil)
        __statsd_publish(:increment, key, 1, sample_rate)
      end

      def statsd_set(key, value = 1, sample_rate = nil)
        __statsd_publish(:set, key, value, sample_rate)
      end

      def statsd_time(key, sample_rate = nil, &block)
        start = Time.now
        result = block.call unless block.nil?
        statsd_timing(key, ((Time.now - start) * 1000).round, sample_rate)
        result
      end

      def statsd_timing(key, value = 1, sample_rate = nil)
        __statsd_publish(:timing, key, value, sample_rate)
      end

      def __statsd_publish(stat_type, key, value = nil, sample_rate = nil)
        payload = { :key => key }
        payload.merge!({ :value => value }) if value
        payload.merge!({ :sample_rate => sample_rate }) if sample_rate

        ::ActiveSupport::Notifications.instrument("#{stat_type}.statsd", payload)
      end

    end
  end
end
