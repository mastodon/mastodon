# encoding: utf-8

require_relative '../converter'
require_relative '../null_converter'

module Necromancer
  # Container for Range converter classes
  module RangeConverters
    SINGLE_DIGIT_MATCHER = /^(\-?\d+)$/.freeze

    DIGIT_MATCHER = /^(-?\d+?)(\.{2}\.?|-|,)(-?\d+)$/.freeze

    LETTER_MATCHER = /^(\w)(\.{2}\.?|-|,)(\w)$/.freeze

    # An object that converts a String to a Range
    class StringToRangeConverter < Converter
      # Convert value to Range type with possible ranges
      #
      # @param [Object] value
      #
      # @example
      #   converter.call('0,9')  # => (0..9)
      #
      # @example
      #   converter.call('0-9')  # => (0..9)
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        case value
        when SINGLE_DIGIT_MATCHER
          ::Range.new($1.to_i, $1.to_i)
        when DIGIT_MATCHER
          ::Range.new($1.to_i, $3.to_i, $2 == '...')
        when LETTER_MATCHER
          ::Range.new($1.to_s, $3.to_s, $2 == '...')
        else
          strict ? fail_conversion_type(value) : value
        end
      end
    end

    def self.load(conversions)
      conversions.register StringToRangeConverter.new(:string, :range)
      conversions.register NullConverter.new(:range, :range)
    end
  end # RangeConverters
end # Necromancer
