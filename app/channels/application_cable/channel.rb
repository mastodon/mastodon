module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected

    def hydrate_status(encoded_message)
      message = ActiveSupport::JSON.decode(encoded_message)

      return [nil, message] if message['type'] == 'delete'

      status             = Status.find_by(id: message['id'])
      message['message'] = FeedManager.instance.inline_render(current_user.account, status)

      [status, message]
    end

    def filter?(status)
      !status.nil? && FeedManager.instance.filter?(:public, status, current_user.account)
    end
  end
end
