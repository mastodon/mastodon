# encoding: utf-8
# frozen_string_literal: true
module Warden
  module Strategies
    class << self
      # Add a strategy and store it in a hash.
      def add(label, strategy = nil, &block)
        strategy ||= Class.new(Warden::Strategies::Base)
        strategy.class_eval(&block) if block_given?

        unless strategy.method_defined?(:authenticate!)
          raise NoMethodError, "authenticate! is not declared in the #{label.inspect} strategy"
        end

        base = Warden::Strategies::Base
        unless strategy.ancestors.include?(base)
          raise "#{label.inspect} is not a #{base}"
        end

        _strategies[label] = strategy
      end

      # Update a previously given strategy.
      def update(label, &block)
        strategy = _strategies[label]
        raise "Unknown strategy #{label.inspect}" unless strategy
        add(label, strategy, &block)
      end

      # Provides access to strategies by label
      # :api: public
      def [](label)
        _strategies[label]
      end

      # Clears all declared.
      # :api: public
      def clear!
        _strategies.clear
      end

      # :api: private
      def _strategies
        @strategies ||= {}
      end
    end # << self
  end # Strategies
end # Warden
