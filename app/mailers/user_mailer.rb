# frozen_string_literal: true

class UserMailer < Devise::Mailer
  layout 'mailer'

  helper :accounts
  helper :application
  helper :instance
  helper :statuses

  helper RoutingHelper

  def confirmation_instructions(user, token, **)
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.unconfirmed_email.presence || @resource.email,
           subject: I18n.t(@resource.pending_reconfirmation? ? 'devise.mailer.reconfirmation_instructions.subject' : 'devise.mailer.confirmation_instructions.subject', instance: @instance),
           template_name: @resource.pending_reconfirmation? ? 'reconfirmation_instructions' : 'confirmation_instructions'
    end
  end

  def reset_password_instructions(user, token, **)
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject')
    end
  end

  def password_change(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.password_change.subject')
    end
  end

  def email_changed(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.email_changed.subject')
    end
  end

  def two_factor_enabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.two_factor_enabled.subject')
    end
  end

  def two_factor_disabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.two_factor_disabled.subject')
    end
  end

  def two_factor_recovery_codes_changed(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.two_factor_recovery_codes_changed.subject')
    end
  end

  def webauthn_enabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_enabled.subject')
    end
  end

  def webauthn_disabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_disabled.subject')
    end
  end

  def webauthn_credential_added(user, webauthn_credential)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @webauthn_credential = webauthn_credential

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_credential.added.subject')
    end
  end

  def webauthn_credential_deleted(user, webauthn_credential)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @webauthn_credential = webauthn_credential

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_credential.deleted.subject')
    end
  end

  def welcome(user)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.welcome.subject')
    end
  end

  def backup_ready(user, backup)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @backup   = backup

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.backup_ready.subject')
    end
  end

  def warning(user, warning)
    @resource = user
    @warning  = warning
    @instance = Rails.configuration.x.local_domain
    @statuses = @warning.statuses.includes(:account, :preloadable_poll, :media_attachments, active_mentions: [:account])

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t("user_mailer.warning.subject.#{@warning.action}", acct: "@#{user.account.local_username_and_domain}")
    end
  end

  def appeal_approved(user, appeal)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @appeal   = appeal

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.appeal_approved.subject', date: l(@appeal.created_at))
    end
  end

  def appeal_rejected(user, appeal)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @appeal   = appeal

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.appeal_rejected.subject', date: l(@appeal.created_at))
    end
  end

  def suspicious_sign_in(user, remote_ip, user_agent, timestamp)
    @resource   = user
    @instance   = Rails.configuration.x.local_domain
    @remote_ip  = remote_ip
    @user_agent = user_agent
    @detection  = Browser.new(user_agent)
    @timestamp  = timestamp.to_time.utc

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.suspicious_sign_in.subject')
    end
  end
end
