# frozen_string_literal: true

class BulkMailer < ApplicationMailer
  include Mastodon::EmailConfigurationHelper

  helper :routing

  default to: -> { @user.email }

  after_action :set_alternative_delivery_settings

  def terms_of_service_changed(user, terms_of_service)
    @user = user
    @terms_of_service = terms_of_service
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, escape_html: true, no_images: true)

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  def announcement_published(user, announcement)
    @user = user
    @announcement = announcement

    I18n.with_locale(locale) do
      mail subject: default_i18n_subject
    end
  end

  private

  def locale
    @user.locale.presence || I18n.default_locale
  end

  def set_alternative_delivery_settings
    return if bulk_mail_configuration&.dig(:smtp_settings, :address).blank?

    mail.delivery_method.settings = smtp_settings(bulk_mail_configuration[:smtp_settings])
  end

  def bulk_mail_configuration
    Rails.configuration.x.email&.bulk_mail
  end
end
