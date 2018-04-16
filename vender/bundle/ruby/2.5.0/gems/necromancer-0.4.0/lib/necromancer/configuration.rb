# coding: utf-8

module Necromancer
  # A global configuration for converters.
  #
  # Used internally by {Necromancer::Context}.
  #
  # @api private
  class Configuration
    # Configure global strict mode
    #
    # @api public
    attr_writer :strict

    # Configure global copy mode
    #
    # @api public
    attr_writer :copy

    # Create a configuration
    #
    # @api private
    def initialize
      @strict = false
      @copy   = true
    end

    # Set or get strict mode
    #
    # @return [Boolean]
    #
    # @api public
    def strict(value = (not_set = true))
      not_set ? @strict : (self.strict = value)
    end

    # Set or get copy mode
    #
    # @return [Boolean]
    #
    # @api public
    def copy(value = (not_set = true))
      not_set ? @copy : (self.copy = value)
    end
  end # Configuration
end # Necromancer
