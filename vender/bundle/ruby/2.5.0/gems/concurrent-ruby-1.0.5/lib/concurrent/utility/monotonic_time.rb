require 'concurrent/synchronization'

module Concurrent

  class_definition = Class.new(Synchronization::LockableObject) do
    def initialize
      @last_time = Time.now.to_f
      super()
    end

    if defined?(Process::CLOCK_MONOTONIC)
      # @!visibility private
      def get_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    elsif Concurrent.on_jruby?
      # @!visibility private
      def get_time
        java.lang.System.nanoTime() / 1_000_000_000.0
      end
    else

      # @!visibility private
      def get_time
        synchronize do
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

  # Clock that cannot be set and represents monotonic time since
  # some unspecified starting point.
  #
  # @!visibility private
  GLOBAL_MONOTONIC_CLOCK = class_definition.new
  private_constant :GLOBAL_MONOTONIC_CLOCK

  # @!macro [attach] monotonic_get_time
  #
  #   Returns the current time a tracked by the application monotonic clock.
  #
  #   @return [Float] The current monotonic time when `since` not given else
  #     the elapsed monotonic time between `since` and the current time
  #
  #   @!macro monotonic_clock_warning
  def monotonic_time
    GLOBAL_MONOTONIC_CLOCK.get_time
  end

  module_function :monotonic_time
end
