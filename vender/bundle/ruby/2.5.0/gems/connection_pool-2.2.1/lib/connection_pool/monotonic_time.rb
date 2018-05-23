# Global monotonic clock from Concurrent Ruby 1.0.
# Copyright (c) Jerry D'Antonio -- released under the MIT license.
# Slightly modified; used with permission.
# https://github.com/ruby-concurrency/concurrent-ruby

require 'thread'

class ConnectionPool

  class_definition = Class.new do

    if defined?(Process::CLOCK_MONOTONIC)

      # @!visibility private
      def get_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

    elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

      # @!visibility private
      def get_time
        java.lang.System.nanoTime() / 1_000_000_000.0
      end

    else

      # @!visibility private
      def initialize
        @mutex = Mutex.new
        @last_time = Time.now.to_f
      end

      # @!visibility private
      def get_time
        @mutex.synchronize do
          now = Time.now.to_f
          if @last_time < now
            @last_time = now
          else # clock has moved back in time
            @last_time += 0.000_001
          end
        end
      end
    end
  end

  ##
  # Clock that cannot be set and represents monotonic time since
  # some unspecified starting point.
  #
  # @!visibility private
  GLOBAL_MONOTONIC_CLOCK = class_definition.new
  private_constant :GLOBAL_MONOTONIC_CLOCK

  class << self
    ##
    # Returns the current time a tracked by the application monotonic clock.
    #
    # @return [Float] The current monotonic time when `since` not given else
    #   the elapsed monotonic time between `since` and the current time
    def monotonic_time
      GLOBAL_MONOTONIC_CLOCK.get_time
    end
  end
end
