# encoding: utf-8

require 'forwardable'

require_relative 'configuration'
require_relative 'conversions'
require_relative 'conversion_target'

module Necromancer
  # A class used by Necromancer to provide user interace
  #
  # @api public
  class Context
    extend Forwardable

    def_delegators :"@conversions", :register

    # Create a context.
    #
    # @api private
    def initialize(&block)
      block.call(configuration) if block_given?
      @conversions = Conversions.new(configuration)
      @conversions.load
    end

    # The configuration object.
    #
    # @example
    #   converter = Necromancer.new
    #   converter.configuration.strict = true
    #
    # @return [Necromancer::Configuration]
    #
    # @api public
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields global configuration to a block.
    #
    # @yield [Necromancer::Configuration]
    #
    # @example
    #   converter = Necromancer.new
    #   converter.configure do |config|
    #     config.strict true
    #   end
    #
    # @api public
    def configure
      yield configuration if block_given?
    end

    # Converts the object
    # @param [Object] value
    #   any object to be converted
    #
    # @api public
    def convert(object = ConversionTarget::UndefinedValue, &block)
      ConversionTarget.for(conversions, object, block)
    end

    # Check if this converter can convert source to target
    #
    # @param [Object] source
    #   the source class
    # @param [Object] target
    #   the target class
    #
    # @return [Boolean]
    #
    # @api public
    def can?(source, target)
      !conversions[source, target].nil?
    rescue NoTypeConversionAvailableError
      false
    end

    # Inspect this context
    #
    # @api public
    def inspect
      %(#<#{self.class}@#{object_id} @config=#{configuration}>)
    end

    protected

    attr_reader :conversions
  end # Context
end # Necromancer
