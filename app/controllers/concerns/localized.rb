# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  def set_locale(&block)
    I18n.with_locale(requested_locale || I18n.default_locale, &block)
  end

  private

  def requested_locale
    requested_locale_name   = available_locale_or_nil(params[:lang])
    requested_locale_name ||= available_locale_or_nil(current_user.locale) if respond_to?(:user_signed_in?) && user_signed_in?
    requested_locale_name ||= http_accept_language if ENV['DEFAULT_LOCALE'].blank?
    requested_locale_name
  end

  def http_accept_language
    HttpAcceptLanguage::Parser.new(request.headers.fetch('Accept-Language')).language_region_compatible_from(I18n.available_locales) if request.headers.key?('Accept-Language')
  end

  def available_locale_or_nil(locale_name)
    locale_name.to_sym if locale_name.present? && I18n.available_locales.include?(locale_name.to_sym)
  end

  def content_locale
    @content_locale ||= I18n.locale.to_s.split(/[_-]/).first
  end
end
