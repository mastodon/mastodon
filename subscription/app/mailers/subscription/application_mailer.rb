module Subscription
  class ApplicationMailer < ActionMailer::Base
    layout 'plain_mailer'

    def send_invite(email, invite)
      @invite = invite
      mail to: email,
          subject: "Here are your invites",
          template_name: 'invite'
    end
  end
end
