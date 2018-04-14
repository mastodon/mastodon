# encoding: utf-8

require_relative '../converter'
require_relative '../null_converter'

module Necromancer
  # Container for Numeric converter classes
  module NumericConverters
    INTEGER_MATCHER = /^[-+]?(\d+)$/.freeze

    FLOAT_MATCHER = /^[-+]?(\d*)(\.\d+)?([eE]?[-+]?\d+)?$/.freeze

    # An object that converts a String to an Integer
    class StringToIntegerConverter < Converter
      # Convert string value to integer
      #
      # @example
      #   converter.call('1abc')  # => 1
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        Integer(value)
      rescue
        strict ? fail_conversion_type(value) : value.to_i
      end
    end

    # An object that converts an Integer to a String
    class IntegerToStringConverter < Converter
      # Convert integer value to string
      #
      # @example
      #   converter.call(1)  # => '1'
      #
      # @api public
      def call(value, _)
        value.to_s
      end
    end

    # An object that converts a String to a Float
    class StringToFloatConverter < Converter
      # Convert string to float value
      #
      # @example
      #   converter.call('1.2') # => 1.2
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        Float(value)
      rescue
        strict ? fail_conversion_type(value) : value.to_f
      end
    end

    # An object that converts a String to a Numeric
    class StringToNumericConverter < Converter
      # Convert string to numeric value
      #
      # @example
      #   converter.call('1.0')  # => 1.0
      #
      # @example
      #   converter.call('1')   # => 1
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        case value
        when INTEGER_MATCHER
          StringToIntegerConverter.new(:string, :integer).call(value, options)
        when FLOAT_MATCHER
          StringToFloatConverter.new(:string, :float).call(value, options)
        else
          strict ? fail_conversion_type(value) : value
        end
      end
    end

    def self.load(conversions)
      conversions.register StringToIntegerConverter.new(:string, :integer)
      conversions.register IntegerToStringConverter.new(:integer, :string)
      conversions.register NullConverter.new(:integer, :integer)
      conversions.register StringToFloatConverter.new(:string, :float)
      conversions.register NullConverter.new(:float, :float)
      conversions.register StringToNumericConverter.new(:string, :numeric)
    end
  end # Conversion
end # Necromancer
