# frozen_string_literal: true

class LanguageDetector
  attr_reader :text, :account

  def initialize(text, account = nil)
    @text = text
    @account = account
  end

  def to_iso_s
    detected_language_code || default_locale.to_sym
  end

  private

  def detected_language_code
    detected_language[:code].to_sym if detected_language_reliable?
  end

  def detected_language
    @_detected_language ||= CLD.detect_language(text_without_urls)
  end

  def detected_language_reliable?
    detected_language[:reliable]
  end

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
