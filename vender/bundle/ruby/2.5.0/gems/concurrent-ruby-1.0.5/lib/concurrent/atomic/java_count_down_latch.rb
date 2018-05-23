if Concurrent.on_jruby?

  module Concurrent

    # @!macro count_down_latch
    # @!visibility private
    # @!macro internal_implementation_note
    class JavaCountDownLatch

      # @!macro count_down_latch_method_initialize
      def initialize(count = 1)
        unless count.is_a?(Fixnum) && count >= 0
          raise ArgumentError.new('count must be in integer greater than or equal zero')
        end
        @latch = java.util.concurrent.CountDownLatch.new(count)
      end

      # @!macro count_down_latch_method_wait
      def wait(timeout = nil)
        if timeout.nil?
          @latch.await
          true
        else
          @latch.await(1000 * timeout, java.util.concurrent.TimeUnit::MILLISECONDS)
        end
      end

      # @!macro count_down_latch_method_count_down
      def count_down
        @latch.countDown
      end

      # @!macro count_down_latch_method_count
      def count
        @latch.getCount
      end
    end
  end
end
