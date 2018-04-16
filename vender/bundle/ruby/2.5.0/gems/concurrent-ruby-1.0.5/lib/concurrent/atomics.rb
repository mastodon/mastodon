# @!macro [new] atomic_reference
#
#   An object reference that may be updated atomically. All read and write
#   operations have java volatile semantic.
#
#   @!macro thread_safe_variable_comparison
#
#   @see http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/AtomicReference.html
#   @see http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/package-summary.html
#
#   @!method initialize
#     @!macro [new] atomic_reference_method_initialize
#       @param [Object] value The initial value.
#
#   @!method get
#     @!macro [new] atomic_reference_method_get
#       Gets the current value.
#       @return [Object] the current value
#
#   @!method set
#     @!macro [new] atomic_reference_method_set
#       Sets to the given value.
#       @param [Object] new_value the new value
#       @return [Object] the new value
#
#   @!method get_and_set
#     @!macro [new] atomic_reference_method_get_and_set
#       Atomically sets to the given value and returns the old value.
#       @param [Object] new_value the new value
#       @return [Object] the old value
#
#   @!method compare_and_set
#     @!macro [new] atomic_reference_method_compare_and_set
#
#       Atomically sets the value to the given updated value if
#       the current value == the expected value.
#
#       @param [Object] old_value the expected value
#       @param [Object] new_value the new value
#
#       @return [Boolean] `true` if successful. A `false` return indicates
#       that the actual value was not equal to the expected value.

require 'concurrent/atomic/atomic_reference'
require 'concurrent/atomic/atomic_boolean'
require 'concurrent/atomic/atomic_fixnum'
require 'concurrent/atomic/cyclic_barrier'
require 'concurrent/atomic/count_down_latch'
require 'concurrent/atomic/event'
require 'concurrent/atomic/read_write_lock'
require 'concurrent/atomic/reentrant_read_write_lock'
require 'concurrent/atomic/semaphore'
require 'concurrent/atomic/thread_local_var'
