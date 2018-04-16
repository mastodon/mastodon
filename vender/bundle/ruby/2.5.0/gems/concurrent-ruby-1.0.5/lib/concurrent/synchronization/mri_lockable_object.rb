module Concurrent
  module Synchronization

    # @!visibility private
    # @!macro internal_implementation_note
    class MriLockableObject < AbstractLockableObject
      protected

      def ns_signal
        @__condition__.signal
        self
      end

      def ns_broadcast
        @__condition__.broadcast
        self
      end
    end


    # @!visibility private
    # @!macro internal_implementation_note
    class MriMutexLockableObject < MriLockableObject
      safe_initialization!

      def initialize(*defaults)
        super(*defaults)
        @__lock__      = ::Mutex.new
        @__condition__ = ::ConditionVariable.new
      end

      protected

      def synchronize
        if @__lock__.owned?
          yield
        else
          @__lock__.synchronize { yield }
        end
      end

      def ns_wait(timeout = nil)
        @__condition__.wait @__lock__, timeout
        self
      end
    end

    # @!visibility private
    # @!macro internal_implementation_note
    class MriMonitorLockableObject < MriLockableObject
      safe_initialization!

      def initialize(*defaults)
        super(*defaults)
        @__lock__      = ::Monitor.new
        @__condition__ = @__lock__.new_cond
      end

      protected

      def synchronize # TODO may be a problem with lock.synchronize { lock.wait }
        @__lock__.synchronize { yield }
      end

      def ns_wait(timeout = nil)
        @__condition__.wait timeout
        self
      end
    end
  end
end
