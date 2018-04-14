require 'concurrent/atomic/abstract_thread_local_var'

if Concurrent.on_jruby?

  module Concurrent

    # @!visibility private
    # @!macro internal_implementation_note
    class JavaThreadLocalVar < AbstractThreadLocalVar

      # @!macro thread_local_var_method_get
      def value
        value = @var.get

        if value.nil?
          default
        elsif value == NULL
          nil
        else
          value
        end
      end

      # @!macro thread_local_var_method_set
      def value=(value)
        @var.set(value)
      end

      protected

      # @!visibility private
      def allocate_storage
        @var = java.lang.ThreadLocal.new
      end
    end
  end
end
