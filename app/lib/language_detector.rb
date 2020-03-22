# frozen_string_literal: true

class LanguageDetector
  include Singleton

  WORDS_THRESHOLD        = 4
  RELIABLE_CHARACTERS_RE = /[\p{Hebrew}\p{Arabic}\p{Syriac}\p{Thaana}\p{Nko}\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/m

  def initialize
    @identifier = CLD3::NNetLanguageIdentifier.new(1, 2048)
  end

  def detect(text, account)
    input_text = prepare_text(text)

    return if input_text.blank?

    detect_language_code(input_text) || default_locale(account)
  end

  def language_names
    @language_names = CLD3::TaskContextParams::LANGUAGE_NAMES.map { |name| iso6391(name.to_s).to_sym }.uniq
  end

  private

  def prepare_text(text)
    simplify_text(text).strip
  end

  def unreliable_input?(text)
    !reliable_input?(text)
  end

  def reliable_input?(text)
    sufficient_text_length?(text) || language_specific_character_set?(text)
  end

  def sufficient_text_length?(text)
    text.split(/\s+/).size >= WORDS_THRESHOLD
  end

  def language_specific_character_set?(text)
    words = text.scan(RELIABLE_CHARACTERS_RE)

    if words.present?
      words.reduce(0) { |acc, elem| acc + elem.size }.to_f / text.size > 0.3
    else
      false
    end
  end

  def detect_language_code(text)
    return if unreliable_input?(text)

    result = @identifier.find_language(text)

    iso6391(result.language.to_s).to_sym if result&.reliable?
  end

  def iso6391(bcp47)
    iso639 = bcp47.split('-').first

    # CLD3 returns grandfathered language code for Hebrew
    return 'he' if iso639 == 'iw'

    ISO_639.find(iso639).alpha2
  end

  def simplify_text(text)
    new_text = remove_html(text)
    new_text.gsub!(FetchLinkCardService::URL_PATTERN, '')
    new_text.gsub!(Account::MENTION_RE, '')
    new_text.gsub!(Tag::HASHTAG_RE) { |string| string.gsub(/[#_]/, '#' => '', '_' => ' ').gsub(/[a-z][A-Z]|[a-zA-Z][\d]/) { |s| s.insert(1, ' ') }.downcase }
    new_text.gsub!(/:#{CustomEmoji::SHORTCODE_RE_FRAGMENT}:/, '')
    new_text.gsub!(/\s+/, ' ')
    new_text
  end

  def new_scrubber
    scrubber = Rails::Html::PermitScrubber.new
    scrubber.tags = %w(br p)
    scrubber
  end

  def scrubber
    @scrubber ||= new_scrubber
  end

  def remove_html(text)
    text = Loofah.fragment(text).scrub!(scrubber).to_s
    text.gsub!('<br>', "\n")
    text.gsub!('</p><p>', "\n\n")
    text.gsub!(/(^<p>|<\/p>$)/, '')
    text
  end

  def default_locale(account)
    account.user_locale&.to_sym || I18n.default_locale if account.local?
  end
end
