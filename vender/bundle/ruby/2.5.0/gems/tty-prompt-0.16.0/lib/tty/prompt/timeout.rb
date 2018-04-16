# encoding: utf-8
# frozen_string_literal: true

require 'timers'

module TTY
  class Prompt
    class Timeout
      # A class responsible for measuring interval
      #
      # @api private
      def initialize(options = {})
        @interval_handler = options.fetch(:interval_handler) { proc {} }
        @lock    = Mutex.new
        @running = true
        @timers  = Timers::Group.new
      end

      def self.timeout(time, interval, &block)
        (@scheduler ||= new).timeout(time, interval, &block)
      end

      # Evalute block and time it
      #
      # @param [Float] time
      #   the time by which to stop
      # @param [Float] interval
      #   the interval time for each tick
      #
      # @api public
      def timeout(time, interval, &job)
        input_thread  = Thread.new { job.() }
        timing_thread = measure_intervals(time, interval, input_thread)
        [input_thread, timing_thread].each(&:join)
      end

      # Cancel this timeout measurement
      #
      # @api public
      def cancel
        return unless @running
        @running = false
      end

      # Measure intervals and terminate input
      #
      # @api private
      def measure_intervals(time, interval, input_thread)
        Thread.new do
          Thread.current.abort_on_exception = true
          start = Time.now

          interval_timer = @timers.every(interval) do
            runtime = Time.now - start
            delta = time - runtime
            if delta.round >= 0
              @interval_handler.(delta.round)
            end
          end

          while @running
            @lock.synchronize {
              @timers.wait
              runtime = Time.now - start
              delta = time - runtime

              if delta <= 0.0
                @running = false
              end
            }
          end

          input_thread.terminate
          interval_timer.cancel
        end
      end
    end # Scheduler
  end # Prompt
end # TTY
