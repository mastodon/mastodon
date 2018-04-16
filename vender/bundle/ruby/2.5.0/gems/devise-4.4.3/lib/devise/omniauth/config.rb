# frozen_string_literal: true

module Devise
  module OmniAuth
    class StrategyNotFound < NameError
      def initialize(strategy)
        @strategy = strategy
        super("Could not find a strategy with name `#{strategy}'. " \
          "Please ensure it is required or explicitly set it using the :strategy_class option.")
      end
    end

    class Config
      attr_accessor :strategy
      attr_reader :args, :options, :provider, :strategy_name

      def initialize(provider, args)
        @provider       = provider
        @args           = args
        @options        = @args.last.is_a?(Hash) ? @args.last : {}
        @strategy       = nil
        @strategy_name  = options[:name] || @provider
        @strategy_class = options.delete(:strategy_class)
      end

      def strategy_class
        @strategy_class ||= find_strategy || autoload_strategy
      end

      def find_strategy
        ::OmniAuth.strategies.find do |strategy_class|
          strategy_class.to_s =~ /#{::OmniAuth::Utils.camelize(strategy_name)}$/ ||
            strategy_class.default_options[:name] == strategy_name
        end
      end

      def autoload_strategy
        name = ::OmniAuth::Utils.camelize(provider.to_s)
        if ::OmniAuth::Strategies.const_defined?(name)
          ::OmniAuth::Strategies.const_get(name)
        else
          raise StrategyNotFound, name
        end
      end
    end
  end
end
