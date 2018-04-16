module Concurrent
  module Synchronization

    # @!visibility private
    # @!macro internal_implementation_note
    class RbxLockableObject < AbstractLockableObject
      safe_initialization!

      def initialize(*defaults)
        super(*defaults)
        @__Waiters__ = []
        @__owner__   = nil
      end

      protected

      def synchronize(&block)
        if @__owner__ == Thread.current
          yield
        else
          result = nil
          Rubinius.synchronize(self) do
            begin
              @__owner__ = Thread.current
              result     = yield
            ensure
              @__owner__ = nil
            end
          end
          result
        end
      end

      def ns_wait(timeout = nil)
        wchan = Rubinius::Channel.new

        begin
          @__Waiters__.push wchan
          Rubinius.unlock(self)
          signaled = wchan.receive_timeout timeout
        ensure
          Rubinius.lock(self)

          if !signaled && !@__Waiters__.delete(wchan)
            # we timed out, but got signaled afterwards,
            # so pass that signal on to the next waiter
            @__Waiters__.shift << true unless @__Waiters__.empty?
          end
        end

        self
      end

      def ns_signal
        @__Waiters__.shift << true unless @__Waiters__.empty?
        self
      end

      def ns_broadcast
        @__Waiters__.shift << true until @__Waiters__.empty?
        self
      end
    end
  end
end
