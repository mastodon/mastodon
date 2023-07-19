module Subscription
  class ApplicationMailer < ActionMailer::Base
    layout 'plain_mailer'

    def send_invite(email, invite)
      @invite = invite
      mail to: email,
          subject: "Here are your invites",
          template_name: 'invite'
    end

    def send_canceled(email, subscription)
      @subscription = subscription
      mail to: email,
          subject: "Your subscription has been canceled",
          template_name: 'canceled'
    end
  end
end
