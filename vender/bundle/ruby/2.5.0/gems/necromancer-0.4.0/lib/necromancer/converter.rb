# encoding: utf-8

require_relative 'configuration'

module Necromancer
  # Abstract converter used internally as a base for other converters
  #
  # @api private
  class Converter
    # Create an abstract converter
    #
    # @param [Object] source
    #   the source object type
    #
    # @param [Object] target
    #   the target object type
    #
    # @api public
    def initialize(source = nil, target = nil)
      @source = source if source
      @target = target if target
      @config ||= Configuration.new
    end

    # Run converter
    #
    # @api private
    def call(*)
      fail NotImplementedError
    end

    # Creates anonymous converter
    #
    # @api private
    def self.create(&block)
      Class.new(self) do
        define_method(:initialize) { |*a| block.call(self, *a) }

        define_method(:call) { |value| convert.call(value) }
      end.new
    end

    # Fail with conversion type error
    #
    # @param [Object] value
    #   the value that cannot be converted
    #
    # @api private
    def fail_conversion_type(value)
      fail ConversionTypeError, "'#{value}' could not be converted " \
                                "from `#{source}` into `#{target}` "
    end

    attr_accessor :source

    attr_accessor :target

    attr_accessor :convert

    protected

    attr_reader :config
  end # Converter
end # Necromancer
