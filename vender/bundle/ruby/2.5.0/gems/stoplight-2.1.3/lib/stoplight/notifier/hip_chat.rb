# coding: utf-8

module Stoplight
  module Notifier
    # @see Base
    class HipChat < Base
      DEFAULT_OPTIONS = {
        color: 'purple',
        message_format: 'text',
        notify: true
      }.freeze

      # @return [Proc]
      attr_reader :formatter
      # @return [::HipChat::Client]
      attr_reader :hip_chat
      # @return [Hash{Symbol => Object}]
      attr_reader :options
      # @return [String]
      attr_reader :room

      # @param hip_chat [::HipChat::Client]
      # @param room [String]
      # @param formatter [Proc, nil]
      # @param options [Hash{Symbol => Object}]
      # @option options [String] :color
      # @option options [String] :message_format
      # @option options [Boolean] :notify
      def initialize(hip_chat, room, formatter = nil, options = {})
        @hip_chat = hip_chat
        @room = room
        @formatter = formatter || Default::FORMATTER
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def notify(light, from_color, to_color, error)
        message = formatter.call(light, from_color, to_color, error)
        hip_chat[room].send('Stoplight', message, options)
        message
      end
    end
  end
end
