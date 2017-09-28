# frozen_string_literal: true

class LanguageDetector
  include Singleton

  def initialize
    @identifier = CLD3::NNetLanguageIdentifier.new(1, 2048)
  end

  def detect(text, account)
    detect_language_code(text) || default_locale(account)
  end

  def language_names
    @language_names =
      CLD3::TaskContextParams::LANGUAGE_NAMES.map { |name| iso6391(name.to_s).to_sym }
                                             .uniq
  end

  private

  def prepare_text(text)
    simplify_text(text).strip
  end

  def detect_language_code(text)
    result = @identifier.find_language(prepare_text(text))
    iso6391(result.language.to_s).to_sym if result.reliable?
  end

  def iso6391(bcp47)
    iso639 = bcp47.split('-').first

    # CLD3 returns grandfathered language code for Hebrew
    return 'he' if iso639 == 'iw'

    ISO_639.find(iso639).alpha2
  end

  def simplify_text(text)
    text.dup.tap do |new_text|
      new_text.gsub!(FetchLinkCardService::URL_PATTERN, '')
      new_text.gsub!(Account::MENTION_RE, '')
      new_text.gsub!(Tag::HASHTAG_RE, '')
      new_text.gsub!(/\s+/, ' ')
    end
  end

  def default_locale(account)
    account.user_locale&.to_sym
  end
end
