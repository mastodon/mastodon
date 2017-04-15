# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  private

  def set_locale
    locale = default_locale

    if user_signed_in?
      begin
        locale = current_user.try(:locale) || default_locale
      rescue I18n::InvalidLocale
        locale = default_locale
      end
    end

    I18n.with_locale(locale) do
      yield
    end
  end

  def default_locale
    ENV.fetch('DEFAULT_LOCALE') {
      user_supplied_locale || I18n.default_locale
    }
  end

  def user_supplied_locale
    http_accept_language.language_region_compatible_from(I18n.available_locales)
  end
end
