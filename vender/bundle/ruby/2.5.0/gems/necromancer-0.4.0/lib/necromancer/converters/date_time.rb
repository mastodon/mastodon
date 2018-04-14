# encoding: utf-8

require 'date'
require 'time'

require_relative '../converter'
require_relative '../null_converter'

module Necromancer
  # Container for Date converter classes
  module DateTimeConverters
    # An object that converts a String to a Date
    class StringToDateConverter < Converter
      # Convert a string value to a Date
      #
      # @example
      #   converter.call("1-1-2015")    # => "2015-01-01"
      #   converter.call("01/01/2015")  # => "2015-01-01"
      #   converter.call("2015-11-12")  # => "2015-11-12"
      #   converter.call("12/11/2015")  # => "2015-11-12"
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        Date.parse(value)
      rescue
        strict ? fail_conversion_type(value) : value
      end
    end

    # An object that converts a String to a DateTime
    class StringToDateTimeConverter < Converter
      # Convert a string value to a DateTime
      #
      # @example
      #  converer.call("1-1-2015")           # => "2015-01-01T00:00:00+00:00"
      #  converer.call("1-1-2015 15:12:44")  # => "2015-01-01T15:12:44+00:00"
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        DateTime.parse(value)
      rescue
        strict ? fail_conversion_type(value) : value
      end
    end

    class StringToTimeConverter < Converter
      # Convert a String value to a Time value
      #
      # @param [String] value
      #   the value to convert
      #
      # @example
      #   converter.call("01-01-2015")       # => 2015-01-01 00:00:00 +0100
      #   converter.call("01-01-2015 08:35") # => 2015-01-01 08:35:00 +0100
      #   converter.call("12:35")            # => 2015-01-04 12:35:00 +0100
      #
      # @api public
      def call(value, options = {})
        strict = options.fetch(:strict, config.strict)
        Time.parse(value)
      rescue
        strict ? fail_conversion_type(value) : value
      end
    end

    def self.load(conversions)
      conversions.register StringToDateConverter.new(:string, :date)
      conversions.register NullConverter.new(:date, :date)
      conversions.register StringToDateTimeConverter.new(:string, :datetime)
      conversions.register NullConverter.new(:datetime, :datetime)
      conversions.register StringToTimeConverter.new(:string, :time)
      conversions.register NullConverter.new(:time, :time)
    end
  end # DateTimeConverters
end # Necromancer
