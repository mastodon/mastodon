module Subscription
  class ApplicationMailer < ::ApplicationMailer
    layout 'mailer'

    helper :application
    helper :instance
    helper :formatting
    helper :routing

    before_action :set_logo

    def send_invite(email, invite)
      @invite = invite
      mail to: email,
          subject: "Here are your invites",
          template_name: 'invite'
    end

    def send_canceled(email, cancel_at)
      @cancel_at = cancel_at
      mail to: email,
          subject: "Your subscription has been canceled",
          template_name: 'canceled'
    end

    protected

    def set_logo
      @logo = ::InstancePresenter.new.email&.file&.url
    end
  end
end
