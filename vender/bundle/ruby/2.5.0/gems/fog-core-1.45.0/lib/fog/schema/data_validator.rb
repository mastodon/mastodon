module Fog
  module Schema
    # This validates a data object against a Ruby based schema to see
    # if they match.
    #
    # * An object matches the schema if +==+ or +===+ returns +true+
    # * Hashes match if all the key's values match the classes given
    #   in the schema as well. This can be configured in the options
    # * Arrays match when every element in the data matches the case
    #   given in the schema.
    #
    # The schema and validation are very simple and probably not
    # suitable for some cases.
    #
    # The following classes can be used to check for special behaviour
    #
    # * Fog::Boolean - value may be +true+ or +false+
    # * Fog::Nullable::Boolean - value may be +true+, +false+ or +nil+
    # * Fog::Nullable::Integer - value may be an Integer or +nil+
    # * Fog::Nullable::String
    # * Fog::Nullable::Time
    # * Fog::Nullable::Float
    # * Fog::Nullable::Hash
    # * Fog::Nullable::Array
    #
    # All the "nullable" objects will pass if the value is of the class
    # or if it is +nil+. This allows you to match APIs that may include
    # keys when the value is not available in some cases but will
    # always be a String. Such as an password that is only displayed
    # on the reset action.
    #
    # The keys for "nullable" resources should always be present but
    # original matcher had a bug that allowed these to also appear to
    # work as optional keys/values.
    #
    # If you need the original behaviour, data with a missing key is
    # still valid, then you may pass the +:allow_optional_rules+
    # option to the #validate method.
    #
    # That is not recommended because you are describing a schema
    # with optional keys in a format that does not support it.
    #
    # Setting +:allow_extra_keys+ as +true+ allows the data to
    # contain keys not declared by the schema and still pass. This
    # is useful if new attributes appear in the API in a backwards
    # compatible manner and can be ignored.
    #
    # This is the behaviour you would have seen with +strict+ being
    # +false+ in the original test helper.
    #
    # @example Schema example
    #     {
    #       "id" => String,
    #       "ram" => Integer,
    #       "disks" => [
    #         "size" => Float
    #       ],
    #       "dns_name" => Fog::Nullable::String,
    #       "active" => Fog::Boolean,
    #       "created" => DateTime
    #     }
    #
    class DataValidator
      # This returns the last message set by the validator
      #
      # @return [String]
      attr_reader :message

      def initialize
        @message = nil
      end

      # Checks if the data structure matches the schema passed in and
      # returns +true+ if it fits.
      #
      # @param [Object] data Hash or Array to check
      # @param [Object] schema Schema pattern to check against
      # @param [Boolean] options
      # @option options [Boolean] :allow_extra_keys
      #     If +true+ does not fail if extra keys are in the data
      #     that are not in the schema.
      # @option options [Boolean] :allow_optional_rules
      #     If +true+ does not fail if extra keys are in the schema
      #     that do not match the data. Not recommended!
      #
      # @return [Boolean] Did the data fit the schema?
      def validate(data, schema, options = {})
        valid = validate_value(schema, data, options)

        unless valid
          @message = "#{data.inspect} does not match #{schema.inspect}"
        end
        valid
      end

      private

      # This contains a slightly modified version of the Hashidator gem
      # but unfortunately the gem does not cope with Array schemas.
      #
      # @see https://github.com/vangberg/hashidator/blob/master/lib/hashidator.rb
      #
      def validate_value(validator, value, options)
        Fog::Logger.write :debug, "[yellow][DEBUG] #{value.inspect} against #{validator.inspect}[/]\n"

        case validator
        when Array
          return false if value.is_a?(Hash)
          value.respond_to?(:all?) && value.all? { |x| validate_value(validator[0], x, options) }
        when Symbol
          value.respond_to? validator
        when Hash
          return false if value.is_a?(Array)

          # When being strict values not specified in the schema are fails
          # Validator is empty but values are not
          return false if !options[:allow_extra_keys] &&
                          value.respond_to?(:empty?) &&
                          !value.empty? &&
                          validator.empty?

          # Validator has rules left but no more values
          return false if !options[:allow_optional_rules] &&
                          value.respond_to?(:empty?) &&
                          value.empty? &&
                          !validator.empty?

          validator.all? do |key, sub_validator|
            Fog::Logger.write :debug, "[blue][DEBUG] #{key.inspect} against #{sub_validator.inspect}[/]\n"
            validate_value(sub_validator, value[key], options)
          end
        else
          result = validator == value
          result = validator === value unless result
          # Repeat unless we have a Boolean already
          unless result.is_a?(TrueClass) || result.is_a?(FalseClass)
            result = validate_value(result, value, options)
          end
          if result
            Fog::Logger.write :debug, "[green][DEBUG] Validation passed: #{value.inspect} against #{validator.inspect}[/]\n"
          else
            Fog::Logger.write :debug, "[red][DEBUG] Validation failed: #{value.inspect} against #{validator.inspect}[/]\n"
          end
          result
        end
      end
    end
  end
end
