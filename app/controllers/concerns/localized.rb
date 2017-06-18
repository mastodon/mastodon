# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    I18n.locale = default_locale
    I18n.locale = current_user.locale if user_signed_in?
  rescue I18n::InvalidLocale
    I18n.locale = default_locale
  end

  def default_locale
    request_locale || env_locale || I18n.default_locale
  end

  def env_locale
    ENV['DEFAULT_LOCALE']
  end

  def request_locale
    preferred_locale || compatible_locale
  end

  def preferred_locale
    http_accept_language.preferred_language_from([env_locale]) ||
      http_accept_language.preferred_language_from(I18n.available_locales)
  end

  def compatible_locale
    http_accept_language.compatible_language_from([env_locale]) ||
      http_accept_language.compatible_language_from(I18n.available_locales)
  end
end
