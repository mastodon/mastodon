# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  private

  def set_locale
    locale   = current_user.locale if respond_to?(:user_signed_in?) && user_signed_in?
    locale ||= session[:locale] ||= default_locale
    locale   = default_locale unless I18n.available_locales.include?(locale.to_sym)

    I18n.with_locale(locale) do
      yield
    end
  end

  def default_locale
    if ENV['DEFAULT_LOCALE'].present?
      I18n.default_locale
    else
      request_locale || I18n.default_locale
    end
  end

  def request_locale
    http_accept_language.language_region_compatible_from(I18n.available_locales)
  end
end
