# coding: utf-8

module Stoplight
  module Notifier
    # @see Base
    class Bugsnag < Base
      DEFAULT_OPTIONS = {
        severity: 'info'
      }.freeze

      StoplightStatusChange = Class.new(Error::Base)

      # @return [Proc]
      attr_reader :formatter
      # @return [::Bugsnag]
      attr_reader :bugsnag
      # @return [Hash{Symbol => Object}]
      attr_reader :options

      # @param bugsnag [::Bugsnag]
      # @param formatter [Proc, nil]
      # @param options [Hash{Symbol => Object}]
      # @option options [String] :severity
      def initialize(bugsnag, formatter = nil, options = {})
        @bugsnag = bugsnag
        @formatter = formatter || Default::FORMATTER
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def notify(light, from_color, to_color, error)
        message = formatter.call(light, from_color, to_color, error)
        bugsnag.notify(StoplightStatusChange.new(message), options)
        message
      end
    end
  end
end
