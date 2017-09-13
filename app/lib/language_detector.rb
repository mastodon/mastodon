# frozen_string_literal: true

class LanguageDetector
  attr_reader :text, :account

  def initialize(text, account = nil)
    @text = text
    @account = account
    @identifier = CLD3::NNetLanguageIdentifier.new(1, 2048)
  end

  def to_iso_s
    detected_language_code || default_locale
  end

  def prepared_text
    simplified_text.strip
  end

  private

  def detected_language_code
    iso6391(result.language).to_sym if detected_language_reliable?
  end

  def iso6391(bcp47)
    iso639 = bcp47.split('-').first

    # CLD3 returns grandfathered language code for Hebrew
    return 'he' if iso639 == 'iw'

    ISO_639.find(iso639).alpha2
  end

  def result
    @result ||= @identifier.find_language(prepared_text)
  end

  def detected_language_reliable?
    result.reliable?
  end

  def simplified_text
    text.dup.tap do |new_text|
      new_text.gsub!(FetchLinkCardService::URL_PATTERN, '')
      new_text.gsub!(Account::MENTION_RE, '')
      new_text.gsub!(Tag::HASHTAG_RE, '')
      new_text.gsub!(/\s+/, ' ')
    end
  end

  def default_locale
    account&.user_locale&.to_sym || nil
  end
end
