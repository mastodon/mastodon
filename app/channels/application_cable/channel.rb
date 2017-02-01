# frozen_string_literal: true

module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected

    def hydrate_status(encoded_message)
      message = OJ.load(encoded_message)

      return [nil, message] if message['event'] == 'delete'

      status_json = OJ.load(message['payload'])
      status      = Status.find(status_json['id'])

      [status, message]
    end

    def filter?(status)
      !status.nil? && FeedManager.instance.filter?(:public, status, current_user.account)
    end
  end
end
