require 'concurrent/atomic_reference/concurrent_update_error'

module Concurrent

  # Define update methods that use direct paths
  #
  # @!visibility private
  # @!macro internal_implementation_note
  module AtomicDirectUpdate

    # @!macro [attach] atomic_reference_method_update
    #
    # Pass the current value to the given block, replacing it
    # with the block's result. May retry if the value changes
    # during the block's execution.
    #
    # @yield [Object] Calculate a new value for the atomic reference using
    #   given (old) value
    # @yieldparam [Object] old_value the starting value of the atomic reference
    #
    # @return [Object] the new value
    def update
      true until compare_and_set(old_value = get, new_value = yield(old_value))
      new_value
    end

    # @!macro [attach] atomic_reference_method_try_update
    #
    # Pass the current value to the given block, replacing it
    # with the block's result. Return nil if the update fails.
    #
    # @yield [Object] Calculate a new value for the atomic reference using
    #   given (old) value
    # @yieldparam [Object] old_value the starting value of the atomic reference
    #
    # @note This method was altered to avoid raising an exception by default.
    # Instead, this method now returns `nil` in case of failure. For more info,
    # please see: https://github.com/ruby-concurrency/concurrent-ruby/pull/336
    #
    # @return [Object] the new value, or nil if update failed
    def try_update
      old_value = get
      new_value = yield old_value

      return unless compare_and_set old_value, new_value

      new_value
    end

    # @!macro [attach] atomic_reference_method_try_update!
    #
    # Pass the current value to the given block, replacing it
    # with the block's result. Raise an exception if the update
    # fails.
    #
    # @yield [Object] Calculate a new value for the atomic reference using
    #   given (old) value
    # @yieldparam [Object] old_value the starting value of the atomic reference
    #
    # @note This behavior mimics the behavior of the original
    # `AtomicReference#try_update` API. The reason this was changed was to
    # avoid raising exceptions (which are inherently slow) by default. For more
    # info: https://github.com/ruby-concurrency/concurrent-ruby/pull/336
    #
    # @return [Object] the new value
    #
    # @raise [Concurrent::ConcurrentUpdateError] if the update fails
    def try_update!
      old_value = get
      new_value = yield old_value
      unless compare_and_set(old_value, new_value)
        if $VERBOSE
          raise ConcurrentUpdateError, "Update failed"
        else
          raise ConcurrentUpdateError, "Update failed", ConcurrentUpdateError::CONC_UP_ERR_BACKTRACE
        end
      end
      new_value
    end
  end
end
