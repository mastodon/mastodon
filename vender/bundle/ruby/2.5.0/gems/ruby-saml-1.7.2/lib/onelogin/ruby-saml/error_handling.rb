require "onelogin/ruby-saml/validation_error"

module OneLogin
  module RubySaml
    module ErrorHandling
      attr_accessor :errors

      # Append the cause to the errors array, and based on the value of soft, return false or raise
      # an exception. soft_override is provided as a means of overriding the object's notion of
      # soft for just this invocation.
      def append_error(error_msg, soft_override = nil)
        @errors << error_msg

        unless soft_override.nil? ? soft : soft_override
          raise ValidationError.new(error_msg)
        end

        false
      end

      # Reset the errors array
      def reset_errors!
        @errors = []
      end
    end
  end
end
