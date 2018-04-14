# coding: utf-8

require 'monitor'

module Stoplight
  module DataStore
    # @see Base
    class Memory < Base
      include MonitorMixin

      def initialize
        @failures = Hash.new { |h, k| h[k] = [] }
        @states = Hash.new { |h, k| h[k] = State::UNLOCKED }
        super() # MonitorMixin
      end

      def names
        synchronize { @failures.keys | @states.keys }
      end

      def get_all(light)
        synchronize { [@failures[light.name], @states[light.name]] }
      end

      def get_failures(light)
        synchronize { @failures[light.name] }
      end

      def record_failure(light, failure)
        synchronize do
          n = light.threshold - 1
          @failures[light.name] = @failures[light.name].first(n)
          @failures[light.name].unshift(failure).size
        end
      end

      def clear_failures(light)
        synchronize { @failures.delete(light.name) }
      end

      def get_state(light)
        synchronize { @states[light.name] }
      end

      def set_state(light, state)
        synchronize { @states[light.name] = state }
      end

      def clear_state(light)
        synchronize { @states.delete(light.name) }
      end
    end
  end
end
