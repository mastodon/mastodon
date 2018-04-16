# coding: utf-8

require 'equatable'
require 'forwardable'

require_relative 'color_parser'
require_relative 'decorator_chain'

module Pastel
  # Wrapes the {DecoratorChain} to allow for easy resolution
  # of string coloring.
  #
  # @api private
  class Delegator
    extend Forwardable
    include Equatable

    def_delegators '@resolver.color', :valid?, :styles, :strip, :decorate,
                   :enabled?, :colored?, :alias_color, :lookup

    def_delegators ColorParser, :parse
    alias_method :undecorate, :parse

    # Create Delegator
    #
    # Used internally by {Pastel}
    #
    # @param [ColorResolver] resolver
    #
    # @param [DecoratorChain] base
    #
    # @api private
    def initialize(resolver, base)
      @resolver = resolver
      @base     = base
    end

    # @api public
    def self.for(resolver, base)
      new(resolver, base)
    end

    remove_method :inspect

    # Object string representation
    #
    # @return [String]
    #
    # @api
    def inspect
      "#<Pastel @styles=#{base.map(&:to_s)}>"
    end
    alias_method :to_s, :inspect

    protected

    attr_reader :base

    attr_reader :resolver

    # Wrap colors
    #
    # @api private
    def wrap(base)
      self.class.new(resolver, base)
    end

    def method_missing(method_name, *args, &block)
      new_base  = base.add(method_name)
      delegator = wrap(new_base)
      if args.empty? && !(method_name.to_sym == :detach)
        delegator
      else
        string = args.join
        string << evaluate_block(&block) if block_given?
        resolver.resolve(new_base, string)
      end
    end

    def respond_to_missing?(name, include_all = false)
      resolver.color.respond_to?(name, include_all) || valid?(name) || super
    end

    # Evaluate color block
    #
    # @api private
    def evaluate_block(&block)
      delegator = self.class.new(resolver, DecoratorChain.empty)
      delegator.instance_eval(&block)
    end
  end # Delegator
end # Pastel
