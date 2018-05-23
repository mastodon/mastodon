# coding: utf-8

module Stoplight
  module Notifier
    module Generic # rubocop:disable Style/Documentation
      # @return [Proc]
      attr_reader :formatter

      # @param object [Object]
      # @param formatter [Proc, nil]
      def initialize(object, formatter = nil)
        @object = object
        @formatter = formatter || Default::FORMATTER
      end

      # @see Base#notify
      def notify(light, from_color, to_color, error)
        message = formatter.call(light, from_color, to_color, error)
        put(message)
        message
      end

      private

      def put(_message)
        raise NotImplementedError
      end
    end
  end
end
