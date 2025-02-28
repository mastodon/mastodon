# frozen_string_literal: true

class UserMailer < Devise::Mailer
  layout 'mailer'

  helper :accounts
  helper :application
  helper :formatting
  helper :instance
  helper :routing
  helper :statuses

  before_action :set_instance

  default to: -> { @resource.email }

  def confirmation_instructions(user, token, *, **)
    @resource = user
    @token    = token

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale) do
      mail to: @resource.unconfirmed_email.presence || @resource.email,
           subject: I18n.t(@resource.pending_reconfirmation? ? 'devise.mailer.reconfirmation_instructions.subject' : 'devise.mailer.confirmation_instructions.subject', instance: @instance),
           template_name: @resource.pending_reconfirmation? ? 'reconfirmation_instructions' : 'confirmation_instructions'
    end
  end

  def reset_password_instructions(user, token, *, **)
    @resource = user
    @token    = token

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def password_change(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def email_changed(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def two_factor_enabled(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def two_factor_disabled(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def two_factor_recovery_codes_changed(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def webauthn_enabled(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def webauthn_disabled(user, *, **)
    @resource = user

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: default_devise_subject
    end
  end

  def webauthn_credential_added(user, webauthn_credential)
    @resource = user
    @webauthn_credential = webauthn_credential

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: I18n.t('devise.mailer.webauthn_credential.added.subject')
    end
  end

  def webauthn_credential_deleted(user, webauthn_credential)
    @resource = user
    @webauthn_credential = webauthn_credential

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale(use_current_locale: true)) do
      mail subject: I18n.t('devise.mailer.webauthn_credential.deleted.subject')
    end
  end

  def welcome(user)
    @resource = user

    return unless @resource.active_for_authentication?

    @suggestions = AccountSuggestions.new(@resource.account).get(5)
    @tags = Trends.tags.query.allowed.limit(5)
    @has_account_fields = @resource.account.display_name.present? || @resource.account.note.present? || @resource.account.avatar.present?
    @has_active_relationships = @resource.account.active_relationships.exists?
    @has_statuses = @resource.account.statuses.exists?

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def backup_ready(user, backup)
    @resource = user
    @backup   = backup

    return unless @resource.active_for_authentication?

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def warning(user, warning)
    @resource = user
    @warning  = warning
    @statuses = @warning.statuses.includes(:account, :preloadable_poll, :media_attachments, active_mentions: [:account])

    I18n.with_locale(locale) do
      mail subject: I18n.t("user_mailer.warning.subject.#{@warning.action}", acct: "@#{user.account.local_username_and_domain}")
    end
  end

  def appeal_approved(user, appeal)
    @resource = user
    @appeal   = appeal

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject(date: l(@appeal.created_at))
    end
  end

  def appeal_rejected(user, appeal)
    @resource = user
    @appeal   = appeal

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject(date: l(@appeal.created_at))
    end
  end

  def suspicious_sign_in(user, remote_ip, user_agent, timestamp)
    @resource   = user
    @remote_ip  = remote_ip
    @user_agent = user_agent
    @detection  = Browser.new(user_agent)
    @timestamp  = timestamp.to_time.utc

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def failed_2fa(user, remote_ip, user_agent, timestamp)
    @resource   = user
    @remote_ip  = remote_ip
    @user_agent = user_agent
    @detection  = Browser.new(user_agent)
    @timestamp  = timestamp.to_time.utc

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def terms_of_service_changed(user, terms_of_service)
    @resource = user
    @terms_of_service = terms_of_service
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, escape_html: true, no_images: true)

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def announcement_published(user, announcement)
    @resource = user
    @announcement = announcement

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  private

  def default_devise_subject
    I18n.t(:subject, scope: ['devise.mailer', action_name])
  end

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end

  def locale(use_current_locale: false)
    @resource.locale.presence || (use_current_locale && I18n.locale) || I18n.default_locale
  end
end
