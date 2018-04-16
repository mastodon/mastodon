# encoding: utf-8

require 'equatable'

module Pastel
  # A class representing detached color
  class Detached
    include Equatable

    # Initialize a detached object
    #
    # @param [Pastel::Color] color
    #   the color instance
    # @param [Array[Symbol]] styles
    #   the styles to be applied
    #
    # @api private
    def initialize(color, *styles)
      @color  = color
      @styles = styles.dup
      freeze
    end

    # Decorate the values corresponding to styles
    #
    # @example
    #
    # @param [String] value
    #   the stirng to decorate with styles
    #
    # @return [String]
    #
    # @api public
    def call(*args)
      value = args.join
      @color.decorate(value, *styles)
    end
    alias_method :[], :call

    # @api public
    def to_proc
      self
    end

    private

    # @api private
    attr_reader :styles
  end # Detached
end # Pastel
