module Aws

  # A utility module that provides a class method that wraps
  # a method such that it generates a deprecation warning when called.
  # Given the following class:
  #
  #     class Example
  #
  #       def do_something
  #       end
  #
  #     end
  #
  # If you want to deprecate the `#do_something` method, you can extend
  # this module and then call `deprecated` on the method (after it
  # has been defined).
  #
  #     class Example
  #
  #       extend Aws::Deprecations
  #
  #       def do_something
  #       end
  #
  #       def do_something_else
  #       end
  #
  #       deprecated :do_something
  #
  #     end
  #
  # The `#do_something` method will continue to function, but will
  # generate a deprecation warning when called.
  #
  # @api private
  module Deprecations

    # @param [Symbol] method_name The name of the deprecated method.
    #
    # @option options [String] :message The warning message to issue
    #   when the deprecated method is called.
    #
    # @option options [Symbol] :use The name of an use
    #   method that should be used.
    #
    def deprecated(method_name, options = {})

      deprecation_msg = options[:message] || begin
        msg = "DEPRECATION WARNING: called deprecated method `#{method_name}' "
        msg << "of an #{self}"
        msg << ", use #{options[:use]} instead" if options[:use]
        msg
      end

      alias_method(:"deprecated_#{method_name}", method_name)

      warned = false # we only want to issue this warning once

      define_method(method_name) do |*args,&block|
        unless warned
          warned = true
          warn(deprecation_msg + "\n" + caller.join("\n"))
        end
        send("deprecated_#{method_name}", *args, &block)
      end
    end

  end
end
