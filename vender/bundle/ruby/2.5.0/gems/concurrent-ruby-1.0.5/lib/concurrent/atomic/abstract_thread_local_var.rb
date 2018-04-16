require 'concurrent/constants'

module Concurrent

  # @!macro thread_local_var
  # @!macro internal_implementation_note
  # @!visibility private
  class AbstractThreadLocalVar

    # @!macro thread_local_var_method_initialize
    def initialize(default = nil, &default_block)
      if default && block_given?
        raise ArgumentError, "Cannot use both value and block as default value"
      end

      if block_given?
        @default_block = default_block
        @default = nil
      else
        @default_block = nil
        @default = default
      end

      allocate_storage
    end

    # @!macro thread_local_var_method_get
    def value
      raise NotImplementedError
    end

    # @!macro thread_local_var_method_set
    def value=(value)
      raise NotImplementedError
    end

    # @!macro thread_local_var_method_bind
    def bind(value, &block)
      if block_given?
        old_value = self.value
        begin
          self.value = value
          yield
        ensure
          self.value = old_value
        end
      end
    end

    protected

    # @!visibility private
    def allocate_storage
      raise NotImplementedError
    end

    # @!visibility private
    def default
      if @default_block
        self.value = @default_block.call
      else
        @default
      end
    end
  end
end
