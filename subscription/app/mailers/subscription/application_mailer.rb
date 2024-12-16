# frozen_string_literal: true

module Subscription
  class ApplicationMailer < ::ApplicationMailer
    layout 'mailer'

    helper :application
    helper :instance
    helper :formatting
    helper :routing

    def send_invite(email, invite)
      @invite = invite
      @app_link = ENV.fetch('APP_LINK', nil)
      mail to: email,
           subject: I18n.t('subscription.invite_subject'),
           template_name: 'invite'
    end

    def send_canceled(email, cancel_at)
      @cancel_at = cancel_at
      @survey_link = ENV.fetch('CANCEL_SURVEY_LINK', nil)
      mail to: email,
           subject: I18n.t('subscription.cancel_subject'),
           template_name: 'canceled'
    end
  end
end
