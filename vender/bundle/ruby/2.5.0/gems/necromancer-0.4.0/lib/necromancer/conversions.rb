# encoding: utf-8

require_relative 'configuration'
require_relative 'converter'
require_relative 'converters/array'
require_relative 'converters/boolean'
require_relative 'converters/date_time'
require_relative 'converters/numeric'
require_relative 'converters/range'

module Necromancer
  # Represents the context used to configure various converters
  # and facilitate type conversion
  #
  # @api public
  class Conversions
    DELIMITER = '->'.freeze

    # Creates a new conversions map
    #
    # @example
    #   conversion = Necromancer::Conversions.new
    #
    # @api public
    def initialize(configuration = Configuration.new, map = {})
      @configuration = configuration
      @converter_map = map.dup
    end

    # Load converters
    #
    # @api private
    def load
      ArrayConverters.load(self)
      BooleanConverters.load(self)
      DateTimeConverters.load(self)
      NumericConverters.load(self)
      RangeConverters.load(self)
    end

    # Retrieve converter for source and target
    #
    # @param [Object] source
    #   the source of conversion
    #
    # @param [Object] target
    #   the target of conversion
    #
    # @return [Converter]
    #  the converter for the source and target
    #
    # @api public
    def [](source, target)
      key = "#{source}#{DELIMITER}#{target}"
      converter_map[key] ||
        converter_map["object#{DELIMITER}#{target}"] ||
        raise_no_type_conversion_available(key)
    end
    alias fetch []

    # Register a converter
    #
    # @example with simple object
    #   conversions.register NullConverter.new(:array, :array)
    #
    # @example with block
    #   conversions.register do |c|
    #     c.source = :array
    #     c.target = :array
    #     c.convert = -> { |val, options| val }
    #   end
    #
    # @api public
    def register(converter = nil, &block)
      converter ||= Converter.create(&block)
      key = generate_key(converter)
      converter = add_config(converter, @configuration)
      return false if converter_map.key?(key)
      converter_map[key] = converter
      true
    end

    # Export all the conversions as hash
    #
    # @return [Hash[String, String]]
    #
    # @api public
    def to_hash
      converter_map.dup
    end

    protected

    # Fail with conversion error
    #
    # @api private
    def raise_no_type_conversion_available(key)
      raise NoTypeConversionAvailableError, "Conversion '#{key}' unavailable."
    end

    # @api private
    def generate_key(converter)
      parts = []
      parts << (converter.source ? converter.source.to_s : 'none')
      parts << (converter.target ? converter.target.to_s : 'none')
      parts.join(DELIMITER)
    end

    # Inject config into converter
    #
    # @api private
    def add_config(converter, config)
      converter.instance_exec(:"@config") do |var|
        instance_variable_set(var, config)
      end
      converter
    end

    # Map of type and conversion
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :converter_map
  end # Conversions
end # Necromancer
