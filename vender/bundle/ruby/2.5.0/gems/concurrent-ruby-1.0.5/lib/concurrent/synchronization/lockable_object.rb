module Concurrent
  module Synchronization

    # @!visibility private
    # @!macro internal_implementation_note
    LockableObjectImplementation = case
                                   when Concurrent.on_cruby? && Concurrent.ruby_version(:<=, 1, 9, 3)
                                     MriMonitorLockableObject
                                   when Concurrent.on_cruby? && Concurrent.ruby_version(:>, 1, 9, 3)
                                     MriMutexLockableObject
                                   when Concurrent.on_jruby?
                                     JRubyLockableObject
                                   when Concurrent.on_rbx?
                                     RbxLockableObject
                                   when Concurrent.on_truffle?
                                     MriMutexLockableObject
                                   else
                                     warn 'Possibly unsupported Ruby implementation'
                                     MriMonitorLockableObject
                                   end
    private_constant :LockableObjectImplementation

    #   Safe synchronization under any Ruby implementation.
    #   It provides methods like {#synchronize}, {#wait}, {#signal} and {#broadcast}.
    #   Provides a single layer which can improve its implementation over time without changes needed to
    #   the classes using it. Use {Synchronization::Object} not this abstract class.
    #
    #   @note this object does not support usage together with
    #     [`Thread#wakeup`](http://ruby-doc.org/core-2.2.0/Thread.html#method-i-wakeup)
    #     and [`Thread#raise`](http://ruby-doc.org/core-2.2.0/Thread.html#method-i-raise).
    #     `Thread#sleep` and `Thread#wakeup` will work as expected but mixing `Synchronization::Object#wait` and
    #     `Thread#wakeup` will not work on all platforms.
    #
    #   @see {Event} implementation as an example of this class use
    #
    #   @example simple
    #     class AnClass < Synchronization::Object
    #       def initialize
    #         super
    #         synchronize { @value = 'asd' }
    #       end
    #
    #       def value
    #         synchronize { @value }
    #       end
    #     end
    #
    # @!visibility private
    class LockableObject < LockableObjectImplementation

      # TODO (pitr 12-Sep-2015): make private for c-r, prohibit subclassing
      # TODO (pitr 12-Sep-2015): we inherit too much ourselves :/

      # @!method initialize(*args, &block)
      #   @!macro synchronization_object_method_initialize

      # @!method synchronize
      #   @!macro synchronization_object_method_synchronize

      # @!method wait_until(timeout = nil, &condition)
      #   @!macro synchronization_object_method_ns_wait_until

      # @!method wait(timeout = nil)
      #   @!macro synchronization_object_method_ns_wait

      # @!method signal
      #   @!macro synchronization_object_method_ns_signal

      # @!method broadcast
      #   @!macro synchronization_object_method_ns_broadcast

    end
  end
end
