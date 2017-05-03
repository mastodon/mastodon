# frozen_string_literal: true

require 'cld'

class LanguageDetector
  attr_reader :text, :account

  def initialize(text, account = nil)
    @text = text
    @account = account
  end

  def to_iso_s
    cld_lang = CLD.detect_language(text_without_urls)
    return cld_lang[:code].to_sym if cld_lang[:reliable]
    default_locale.to_sym
  end

  private

  def text_without_urls
    text.dup.tap do |new_text|
      URI.extract(new_text).each do |url|
        new_text.gsub!(url, '')
      end
    end
  end

  def default_locale
    account&.user&.locale || I18n.default_locale
  end
end
