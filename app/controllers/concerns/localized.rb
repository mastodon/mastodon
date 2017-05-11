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
    ENV.fetch('DEFAULT_LOCALE') do
      user_supplied_locale || I18n.default_locale
    end
  end

  def user_supplied_locale
    http_accept_language.language_region_compatible_from(I18n.available_locales)
  end
end
