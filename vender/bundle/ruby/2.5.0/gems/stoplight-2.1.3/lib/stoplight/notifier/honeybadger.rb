# coding: utf-8

module Stoplight
  module Notifier
    # @see Base
    class Honeybadger < Base
      DEFAULT_OPTIONS = {
        parameters: {},
        session: {},
        context: {}
      }.freeze

      # @return [String]
      attr_reader :api_key
      # @return [Proc]
      attr_reader :formatter
      # @return [Hash{Symbol => Object}]
      attr_reader :options

      # @param api_key [String]
      # @param formatter [Proc, nil]
      # @param options [Hash{Symbol => Object}]
      # @option options [Hash] :parameters
      # @option options [Hash] :session
      # @option options [Hash] :context
      def initialize(api_key, formatter = nil, options = {})
        @api_key = api_key
        @formatter = formatter || Default::FORMATTER
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def notify(light, from_color, to_color, error)
        message = formatter.call(light, from_color, to_color, error)
        h = options.merge(
          api_key: api_key,
          error_message: message,
          backtrace: (error.backtrace if error)
        )
        ::Honeybadger.notify(h)
        message
      end
    end
  end
end
