# frozen_string_literal: true

class UserMailer < Devise::Mailer
  layout 'mailer'

  helper :instance

  def confirmation_instructions(user, token, _opts = {})
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.unconfirmed_email.blank? ? @resource.email : @resource.unconfirmed_email, subject: I18n.t('devise.mailer.confirmation_instructions.subject', instance: @instance)
    end
  end

  def new_user_waiting_for_approval(recipient, user, _opts = {})
    @me       = recipient
    @resource = user
    @instance = Rails.configuration.x.local_domain

    I18n.with_locale(@me.locale || I18n.default_locale) do
      mail to: @me.email, subject: I18n.t('devise.mailer.new_user_waiting_for_approval.subject', acct: @resource.account.local_username_and_domain)
    end
  end

  def reset_password_instructions(user, token, _opts = {})
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject')
    end
  end

  def password_change(user, _opts = {})
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.password_change.subject')
    end
  end
end
