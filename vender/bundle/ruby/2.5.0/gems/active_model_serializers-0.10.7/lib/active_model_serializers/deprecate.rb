##
# Provides a single method +deprecate+ to be used to declare when
# something is going away.
#
#     class Legacy
#       def self.klass_method
#         # ...
#       end
#
#       def instance_method
#         # ...
#       end
#
#       extend ActiveModelSerializers::Deprecate
#       deprecate :instance_method, "ActiveModelSerializers::NewPlace#new_method"
#
#       class << self
#         extend ActiveModelSerializers::Deprecate
#         deprecate :klass_method, :none
#       end
#     end
#
# Adapted from https://github.com/rubygems/rubygems/blob/1591331/lib/rubygems/deprecate.rb
module ActiveModelSerializers
  module Deprecate
    ##
    # Simple deprecation method that deprecates +name+ by wrapping it up
    # in a dummy method. It warns on each call to the dummy method
    # telling the user of +replacement+ (unless +replacement+ is :none) that it is planned to go away.

    def deprecate(name, replacement)
      old = "_deprecated_#{name}"
      alias_method old, name
      class_eval do
        define_method(name) do |*args, &block|
          target = is_a?(Module) ? "#{self}." : "#{self.class}#"
          msg = ["NOTE: #{target}#{name} is deprecated",
                 replacement == :none ? ' with no replacement' : "; use #{replacement} instead",
                 "\n#{target}#{name} called from #{ActiveModelSerializers.location_of_caller.join(':')}"]
          warn "#{msg.join}."
          send old, *args, &block
        end
      end
    end

    def delegate_and_deprecate(method, delegee)
      delegate method, to: delegee
      deprecate method, "#{delegee.name}."
    end

    module_function :deprecate
    module_function :delegate_and_deprecate
  end
end
