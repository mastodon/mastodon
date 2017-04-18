# frozen_string_literal: true

class LanguageDetector
  attr_reader :text, :account

  def initialize(text, account = nil)
    @text = text
    @account = account
  end

  def to_iso_s
    WhatLanguage.new(:all).language_iso(text) || default_locale.to_sym
  end

  private

  def default_locale
    account&.user&.locale || I18n.default_locale
  end
end
