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
    if ENV['DEFAULT_LOCALE'].present?
      I18n.default_locale
    else
      request_locale || I18n.default_locale
    end
  end

  def request_locale
    preferred_locale || compatible_locale
  end

  def preferred_locale
    http_accept_language.preferred_language_from(I18n.available_locales)
  end

  def compatible_locale
    http_accept_language.compatible_language_from(I18n.available_locales)
  end
end
