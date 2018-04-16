module ThreadSafe
  module Util
    AtomicReference =
      if defined?(Rubinius::AtomicReference)
        # An overhead-less atomic reference.
        Rubinius::AtomicReference
      else
        begin
          require 'atomic'
          defined?(Atomic::InternalReference) ? Atomic::InternalReference : Atomic
        rescue LoadError, NameError
          class FullLockingAtomicReference
            def initialize(value = nil)
              @___mutex = Mutex.new
              @___value = value
            end

            def get
              @___mutex.synchronize { @___value }
            end
            alias_method :value, :get

            def set(new_value)
              @___mutex.synchronize { @___value = new_value }
            end
            alias_method :value=, :set

            def compare_and_set(old_value, new_value)
              return false unless @___mutex.try_lock
              begin
                return false unless @___value.equal? old_value
                @___value = new_value
              ensure
                @___mutex.unlock
              end
              true
            end
          end

          FullLockingAtomicReference
        end
      end
  end
end
