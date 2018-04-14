require 'concurrent/thread_safe/util'
require 'concurrent/thread_safe/util/volatile'

module Concurrent

  # @!visibility private
  module ThreadSafe

    # @!visibility private
    module Util

      # Provides a cheapest possible (mainly in terms of memory usage) +Mutex+
      # with the +ConditionVariable+ bundled in.
      #
      # Usage:
      #   class A
      #     include CheapLockable
      #
      #     def do_exlusively
      #       cheap_synchronize { yield }
      #     end
      #
      #     def wait_for_something
      #       cheap_synchronize do
      #         cheap_wait until resource_available?
      #         do_something
      #         cheap_broadcast # wake up others
      #       end
      #     end
      #   end
      # 
      # @!visibility private
      module CheapLockable
        private
        engine = defined?(RUBY_ENGINE) && RUBY_ENGINE
        if engine == 'rbx'
          # Making use of the Rubinius' ability to lock via object headers to avoid the overhead of the extra Mutex objects.
          def cheap_synchronize
            Rubinius.lock(self)
            begin
              yield
            ensure
              Rubinius.unlock(self)
            end
          end

          def cheap_wait
            wchan = Rubinius::Channel.new

            begin
              waiters = @waiters ||= []
              waiters.push wchan
              Rubinius.unlock(self)
              signaled = wchan.receive_timeout nil
            ensure
              Rubinius.lock(self)

              unless signaled or waiters.delete(wchan)
                # we timed out, but got signaled afterwards (e.g. while waiting to
                # acquire @lock), so pass that signal on to the next waiter
                waiters.shift << true unless waiters.empty?
              end
            end

            self
          end

          def cheap_broadcast
            waiters = @waiters ||= []
            waiters.shift << true until waiters.empty?
            self
          end
        elsif engine == 'jruby'
          # Use Java's native synchronized (this) { wait(); notifyAll(); } to avoid the overhead of the extra Mutex objects
          require 'jruby'

          def cheap_synchronize
            JRuby.reference0(self).synchronized { yield }
          end

          def cheap_wait
            JRuby.reference0(self).wait
          end

          def cheap_broadcast
            JRuby.reference0(self).notify_all
          end
        else
          require 'thread'

          extend Volatile
          attr_volatile :mutex

          # Non-reentrant Mutex#syncrhonize
          def cheap_synchronize
            true until (my_mutex = mutex) || cas_mutex(nil, my_mutex = Mutex.new)
            my_mutex.synchronize { yield }
          end

          # Releases this object's +cheap_synchronize+ lock and goes to sleep waiting for other threads to +cheap_broadcast+, reacquires the lock on wakeup.
          # Must only be called in +cheap_broadcast+'s block.
          def cheap_wait
            conditional_variable = @conditional_variable ||= ConditionVariable.new
            conditional_variable.wait(mutex)
          end

          # Wakes up all threads waiting for this object's +cheap_synchronize+ lock.
          # Must only be called in +cheap_broadcast+'s block.
          def cheap_broadcast
            if conditional_variable = @conditional_variable
              conditional_variable.broadcast
            end
          end
        end
      end
    end
  end
end
