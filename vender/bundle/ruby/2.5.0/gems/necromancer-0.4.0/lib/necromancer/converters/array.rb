# encoding: utf-8

require 'set'

require_relative '../converter'

module Necromancer
  # Container for Array converter classes
  module ArrayConverters
    # An object that converts a String to an Array
    class StringToArrayConverter < Converter
      # Convert string value to array
      #
      # @example
      #   converter.call('a, b, c')  # => ['a', 'b', 'c']
      #
      # @example
      #   converter.call('1 - 2 - 3')  # => [1, 2, 3]
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        case value.to_s
        when /^\s*?((\d+)(\s*(,|-)\s*)?)+\s*?$/
          value.to_s.split($4).map(&:to_i)
        when /^((\w)(\s*(,|-)\s*)?)+$/
          value.to_s.split($4)
        else
          strict ? fail_conversion_type(value) : Array(value)
        end
      end
    end

    # An object that converts an array to an array with numeric values
    class ArrayToNumericConverter < Converter
      # Convert an array to an array of numeric values
      #
      # @example
      #   converter.call(['1', '2.3', '3.0])  # => [1, 2.3, 3.0]
      #
      # @param [Array] value
      #   the value to convert
      #
      # @api public
      def call(value, options = {})
        numeric_converter = NumericConverters::StringToNumericConverter.new(:string, :numeric)
        value.reduce([]) do |acc, el|
          acc << numeric_converter.call(el, options)
        end
      end
    end

    # An object that converts an array to an array with boolean values
    class ArrayToBooleanConverter < Converter
      # @example
      #   converter.call(['t', 'f', 'yes', 'no']) # => [true, false, true, false]
      #
      # @param [Array] value
      #   the array value to boolean
      #
      # @api public
      def call(value, options = {})
        boolean_converter = BooleanConverters::StringToBooleanConverter.new(:string, :boolean)
        value.reduce([]) do |acc, el|
          acc << boolean_converter.call(el, options)
        end
      end
    end

    # An object that converts an object to an array
    class ObjectToArrayConverter < Converter
      # Convert an object to an array
      #
      # @example
      #   converter.call({x: 1})   # => [[:x, 1]]
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        begin
          Array(value)
        rescue
          strict ? fail_conversion_type(value) : value
        end
      end
    end

    # An object that converts an array to a set
    class ArrayToSetConverter < Converter
      # Convert an array to a set
      #
      # @example
      #   converter.call([:x, :y, :x, 1, 2, 1])  # => <Set: {:x, :y, 1, 2}>
      #
      # @param [Array] value
      #   the array to convert
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        begin
          value.to_set
        rescue
          strict ? fail_conversion_type(value) : value
        end
      end
    end

    def self.load(conversions)
      conversions.register NullConverter.new(:array, :array)
      conversions.register StringToArrayConverter.new(:string, :array)
      conversions.register ArrayToNumericConverter.new(:array, :numeric)
      conversions.register ArrayToBooleanConverter.new(:array, :boolean)
      conversions.register ObjectToArrayConverter.new(:object, :array)
      conversions.register ObjectToArrayConverter.new(:hash, :array)
    end
  end # ArrayConverters
end # Necromancer
