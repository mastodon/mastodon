# coding: utf-8

module Stoplight
  module Notifier
    # @see Base
    class Slack < Base
      include Generic

      # @return [::Slack::Notifier]
      def slack
        @object
      end

      private

      def put(message)
        slack.ping(message)
      end
    end
  end
end
