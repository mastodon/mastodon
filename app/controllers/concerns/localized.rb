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
      http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
    }
  end
end
