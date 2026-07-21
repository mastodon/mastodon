# frozen_string_literal: true

module Extractor
  MAX_DOMAIN_LENGTH = 253

  UTS58 = Uts58::Extractor.new.tap { |e| e.max_length = 4096 }

  # Matches ASCII or fullwidth at-signs, to quickly detect whether
  # something may contain a mention.
  AT_SIGNS = /[@＠]/

  # Mirrors twitter-text's :end_mention_match. Used to discard
  # candidates such as "@noël@example.com", which is not "@no"
  # followed by a separate word. Ranges copied verbatim from
  # twitter-text 3.1.0 (regex.rb LATIN_ACCENTS). Source as explicit
  # \u escapes because several of these (notably U+0300-036F combining
  # marks) have no visible glyph and would be silently corrupted by
  # anything that normalizes Unicode in source files.
  LATIN_ACCENTS = [
    "À-Ö", "Ø-ö", "ø-ÿ",
    "Ā-ɏ", "ɓ-ɔ", "ɖ-ɗ",
    "ə", "ɛ", "ɣ", "ɨ", "ɯ",
    "ɲ", "ʉ", "ʋ", "ʻ",
    "̀-ͯ", "Ḁ-ỿ"
  ].join.freeze
  END_MENTION_MATCH = %r{\A(?:#{AT_SIGNS}|[#{LATIN_ACCENTS}]+|://)}o

  module_function

  # URL extraction and overlap resolution go through Uts58 (UTS #58).
  # xmpp: and magnet: URIs are handled by separate small extractors
  # below.
  def extract_urls_with_indices(text, options = {})
    UTS58.extract_urls_with_indices(text, options)
  end

  def remove_overlapping_entities(entities)
    UTS58.remove_overlapping_entities(entities)
  end

  def extract_hashtags(text)
    hashtags = []
    extract_hashtags_with_indices(text) { |hashtag, _, _| hashtags << hashtag }
    hashtags
  end

  def extract_entities_with_indices(text, options = {}, &block)
    entities = extract_urls_with_indices(text, options) +
               extract_hashtags_with_indices(text, check_url_overlap: false) +
               extract_mentions_or_lists_with_indices(text) +
               extract_xmpp_uris_with_indices(text) +
               extract_magnet_uris_with_indices(text)

    # Reject any URL-bearing entity whose match contains a '<'. The
    # character is reserved by RFC 3986 and has been used for XSS (see
    # spec files).
    entities = entities.reject { |entity| entity[:url]&.include?('<') }

    return [] if entities.empty?

    entities = remove_overlapping_entities(entities)
    entities.each(&block) if block
    entities
  end

  def extract_mentions_or_lists_with_indices(text)
    return [] unless text && AT_SIGNS.match?(text)

    possible_entries = []

    text.scan(Account::MENTION_RE) do |screen_name, _|
      match_data = $LAST_MATCH_INFO
      after      = ::Regexp.last_match.post_match

      unless END_MENTION_MATCH.match?(after)
        _, domain = screen_name.split('@')

        next if domain.present? && domain.length > MAX_DOMAIN_LENGTH

        start_position = match_data.begin(1) - 1
        end_position   = match_data.end(1)

        possible_entries << {
          screen_name: screen_name,
          indices: [start_position, end_position],
        }
      end
    end

    if block_given?
      possible_entries.each do |mention|
        yield mention[:screen_name], mention[:indices].first, mention[:indices].last
      end
    end

    possible_entries
  end

  def extract_hashtags_with_indices(text, _options = {})
    return [] unless text&.index(/[#＃]/)

    possible_entries = []

    text.scan(Tag::HASHTAG_RE) do |hash_text, _|
      match_data     = $LAST_MATCH_INFO
      start_position = match_data.begin(1) - 1
      end_position   = match_data.end(1)
      after          = ::Regexp.last_match.post_match

      if after.start_with?('://')
        hash_text.match(/(.+)(https?\Z)/) do |matched|
          hash_text     = matched[1]
          end_position -= matched[2].length
        end
      end

      possible_entries << {
        hashtag: hash_text,
        indices: [start_position, end_position],
      }
    end

    if block_given?
      possible_entries.each do |tag|
        yield tag[:hashtag], tag[:indices].first, tag[:indices].last
      end
    end

    possible_entries
  end

  # Matches xmpp: URIs liberally — anything up to whitespace, then trim
  # common trailing punctuation. The shared XSS reject in
  # #extract_entities_with_indices drops matches that ate a '<'.
  TRAILING_URI_PUNCT = /[.,;:!?)\]}'"`]+\z/

  def extract_xmpp_uris_with_indices(text)
    return [] unless text&.include?('xmpp:')

    text.to_enum(:scan, /(?<![\p{L}\p{N}_])xmpp:\S+/).filter_map do
      match = ::Regexp.last_match
      url   = match[0].sub(TRAILING_URI_PUNCT, '')
      next unless url.match?(/\Axmpp:.*[.@]/)

      { url: url, indices: [match.begin(0), match.begin(0) + url.length] }
    end
  end

  # Matches magnet: URIs simply (anything up to whitespace) and only
  # accepts the result if it has an xt= parameter, the one piece a
  # magnet URI is meaningless without.
  def extract_magnet_uris_with_indices(text)
    return [] unless text&.include?('magnet:?')

    text.to_enum(:scan, /(?<![\p{L}\p{N}_])magnet:\?\S+/).filter_map do
      match = ::Regexp.last_match
      url   = match[0].sub(TRAILING_URI_PUNCT, '')
      next unless url.match?(/[?&]xt=/)

      { url: url, indices: [match.begin(0), match.begin(0) + url.length] }
    end
  end
end
