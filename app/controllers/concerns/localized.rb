# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  def set_locale
    I18n.locale = current_user.try(:locale) || default_locale
  rescue I18n::InvalidLocale
    I18n.locale = default_locale
  end

  def default_locale
    ENV.fetch('DEFAULT_LOCALE') { http_accept_language.compatible_language_from(I18n.available_locales) }
  end
end
