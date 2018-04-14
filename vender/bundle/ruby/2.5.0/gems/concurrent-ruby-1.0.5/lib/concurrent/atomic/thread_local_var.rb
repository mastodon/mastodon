require 'concurrent/atomic/ruby_thread_local_var'
require 'concurrent/atomic/java_thread_local_var'
require 'concurrent/utility/engine'

module Concurrent

  ###################################################################

  # @!macro [new] thread_local_var_method_initialize
  #
  #   Creates a thread local variable.
  #
  #   @param [Object] default the default value when otherwise unset
  #   @param [Proc] default_block Optional block that gets called to obtain the
  #     default value for each thread

  # @!macro [new] thread_local_var_method_get
  #
  #   Returns the value in the current thread's copy of this thread-local variable.
  #
  #   @return [Object] the current value

  # @!macro [new] thread_local_var_method_set
  #
  #   Sets the current thread's copy of this thread-local variable to the specified value.
  #
  #   @param [Object] value the value to set
  #   @return [Object] the new value

  # @!macro [new] thread_local_var_method_bind
  #
  #   Bind the given value to thread local storage during
  #   execution of the given block.
  #
  #   @param [Object] value the value to bind
  #   @yield the operation to be performed with the bound variable
  #   @return [Object] the value


  ###################################################################

  # @!macro [new] thread_local_var_public_api
  #
  #   @!method initialize(default = nil)
  #     @!macro thread_local_var_method_initialize
  #
  #   @!method value
  #     @!macro thread_local_var_method_get
  #
  #   @!method value=(value)
  #     @!macro thread_local_var_method_set
  #
  #   @!method bind(value, &block)
  #     @!macro thread_local_var_method_bind

  ###################################################################

  # @!visibility private
  # @!macro internal_implementation_note
  ThreadLocalVarImplementation = case
                                 when Concurrent.on_jruby?
                                   JavaThreadLocalVar
                                 else
                                   RubyThreadLocalVar
                                 end
  private_constant :ThreadLocalVarImplementation

  # @!macro [attach] thread_local_var
  #
  #   A `ThreadLocalVar` is a variable where the value is different for each thread.
  #   Each variable may have a default value, but when you modify the variable only
  #   the current thread will ever see that change.
  #
  #   @!macro thread_safe_variable_comparison
  #
  #   @example
  #     v = ThreadLocalVar.new(14)
  #     v.value #=> 14
  #     v.value = 2
  #     v.value #=> 2
  #
  #   @example
  #     v = ThreadLocalVar.new(14)
  #
  #     t1 = Thread.new do
  #       v.value #=> 14
  #       v.value = 1
  #       v.value #=> 1
  #     end
  #
  #     t2 = Thread.new do
  #       v.value #=> 14
  #       v.value = 2
  #       v.value #=> 2
  #     end
  #
  #     v.value #=> 14
  #
  #   @see https://docs.oracle.com/javase/7/docs/api/java/lang/ThreadLocal.html Java ThreadLocal
  #
  # @!macro thread_local_var_public_api
  class ThreadLocalVar < ThreadLocalVarImplementation
  end
end
