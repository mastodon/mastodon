# frozen_string_literal: true

class UserMailer < Devise::Mailer
  layout 'mailer'

  helper :instance

  def confirmation_instructions(user, token, _opts = {})
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.unconfirmed_email.blank? ? @resource.email : @resource.unconfirmed_email, subject: I18n.t('devise.mailer.confirmation_instructions.subject', instance: @instance)
    end
  end

  def reset_password_instructions(user, token, _opts = {})
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject')
    end
  end

  def password_change(user, _opts = {})
    @resource = user
    @instance = Rails.configuration.x.local_domain

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.password_change.subject')
    end
  end
end
