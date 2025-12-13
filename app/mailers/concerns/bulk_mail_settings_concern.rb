# frozen_string_literal: true

module BulkMailSettingsConcern
  include ActiveSupport::Concern
  include Mastodon::EmailConfigurationHelper

  private

  def use_bulk_mail_delivery_settings
    return if bulk_mail_configuration&.dig(:smtp_settings, :address).blank?

    mail.delivery_method.settings = convert_smtp_settings(bulk_mail_configuration[:smtp_settings])
  end

  def bulk_mail_configuration
    Rails.configuration.x.email&.bulk_mail
  end
end
