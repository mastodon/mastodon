require "statsd-ruby"

module NSA
  module Statsd
    module Subscriber

      EXPECTED_RESPONDABLE_METHODS = %i( count decrement gauge increment set time timing ).freeze

      def statsd_subscribe(backend)
        unless backend_valid?(backend)
          fail "Backend must respond to the following methods:\n\t#{EXPECTED_RESPONDABLE_METHODS.join(", ")}"
        end

        ::ActiveSupport::Notifications.subscribe(/.statsd$/) do |name, start, finish, id, payload|
          __send_event_to_statsd(backend, name, start, finish, id, payload)
        end
      end

      def __send_event_to_statsd(backend, name, start, finish, id, payload)
        action = name.to_s.split(".").first || :count

        key_name = payload[:key]
        sample_rate = payload.fetch(:sample_rate, 1)

        case action.to_sym
        when :count, :timing, :set, :gauge then
          value = payload.fetch(:value) { 1 }
          backend.__send__(action, key_name, value, sample_rate)
        when :increment, :decrement then
          backend.__send__(action, key_name, sample_rate)
        end
      end

      def backend_valid?(backend)
        EXPECTED_RESPONDABLE_METHODS.all? do |method_name|
          backend.respond_to?(method_name)
        end
      end

    end
  end
end

