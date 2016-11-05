module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected

    def hydrate_status(encoded_message)
      message = ActiveSupport::JSON.decode(encoded_message)
      status  = Status.find_by(id: message['id'])
      message['message'] = FeedManager.instance.inline_render(current_user.account, status)

      [status, message]
    end

    def filter?(status)
      status.nil? || current_user.account.blocking?(status.account) || (status.reblog? && current_user.account.blocking?(status.reblog.account))
    end
  end
end
