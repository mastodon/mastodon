# frozen_string_literal: true

class LanguageDetector
  attr_reader :text, :account

  def initialize(text, account = nil)
    @text = text
    @account = account
    @identifier = CLD3::NNetLanguageIdentifier.new(1, 2048)
  end

  def to_iso_s
    detected_language_code || default_locale.to_sym
  end

  private

  def detected_language_code
    result.language.to_sym if detected_language_reliable?
  end

  def result
    @result ||= @identifier.find_language(text_without_urls)
  end

  def detected_language_reliable?
    result.reliable?
  end

  def text_without_urls
    text.dup.tap do |new_text|
      URI.extract(new_text).each do |url|
        new_text.gsub!(url, '')
      end
    end
  end

  def default_locale
    account&.user_locale || I18n.default_locale
  end
end
