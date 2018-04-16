# coding: utf-8

require 'equatable'

module Pastel
  # Collects a list of decorators for styling a string
  #
  # @api private
  class DecoratorChain
    include Enumerable
    include Equatable

    def initialize(decorators = [])
      @decorators = decorators
    end

    # Add decorator
    #
    # @api public
    def add(decorator)
      if decorators.include?(decorator)
        self.class.new(decorators)
      else
        self.class.new(decorators + [decorator])
      end
    end

    # Iterate over list of decorators
    #
    # @api public
    def each(&block)
      decorators.each(&block)
    end

    # Create an empty decorator chain
    #
    # @return [DecoratorChain]
    #
    # @api public
    def self.empty
      new([])
    end

    protected

    attr_reader :decorators
  end # DecoratorChain
end # Patel
