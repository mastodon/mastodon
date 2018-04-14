# frozen_string_literal: true
module Rake
  ##
  # Mixin for creating easily cloned objects.

  module Cloneable # :nodoc:
    # The hook that is invoked by 'clone' and 'dup' methods.
    def initialize_copy(source)
      super
      source.instance_variables.each do |var|
        src_value  = source.instance_variable_get(var)
        value = src_value.clone rescue src_value
        instance_variable_set(var, value)
      end
    end
  end
end
