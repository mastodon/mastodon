# coding: utf-8

module Stoplight
  module Notifier
    # @see Base
    class Raven < Base
      DEFAULT_OPTIONS = {
        extra: {}
      }.freeze

      # @return [::Raven::Configuration]
      attr_reader :configuration
      # @return [Proc]
      attr_reader :formatter
      # @return [Hash{Symbol => Object}]
      attr_reader :options

      # @param api_key [String]
      # @param formatter [Proc, nil]
      # @param options [Hash{Symbol => Object}]
      # @option options [Hash] :extra
      def initialize(configuration, formatter = nil, options = {})
        @configuration = configuration
        @formatter = formatter || Default::FORMATTER
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def notify(light, from_color, to_color, error)
        message = formatter.call(light, from_color, to_color, error)

        h = options.merge(
          configuration: configuration,
          backtrace: (error.backtrace if error)
        )
        ::Raven.capture_message(message, h)
        message
      end
    end
  end
end
