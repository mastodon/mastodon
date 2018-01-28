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
    new_text = remove_html(text)
    new_text.gsub!(FetchLinkCardService::URL_PATTERN, '')
    new_text.gsub!(Account::MENTION_RE, '')
    new_text.gsub!(Tag::HASHTAG_RE, '')
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
    account.user_locale&.to_sym
  end
end
