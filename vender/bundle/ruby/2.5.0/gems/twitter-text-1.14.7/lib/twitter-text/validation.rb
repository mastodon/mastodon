require 'unf'

module Twitter
  module Validation extend self
    MAX_LENGTH = 140

    DEFAULT_TCO_URL_LENGTHS = {
      :short_url_length => 23,
      :short_url_length_https => 23,
      :characters_reserved_per_media => 23
    }.freeze

    # Returns the length of the string as it would be displayed. This is equivilent to the length of the Unicode NFC
    # (See: http://www.unicode.org/reports/tr15). This is needed in order to consistently calculate the length of a
    # string no matter which actual form was transmitted. For example:
    #
    #     U+0065  Latin Small Letter E
    # +   U+0301  Combining Acute Accent
    # ----------
    # =   2 bytes, 2 characters, displayed as é (1 visual glyph)
    #     … The NFC of {U+0065, U+0301} is {U+00E9}, which is a single chracter and a +display_length+ of 1
    #
    # The string could also contain U+00E9 already, in which case the canonicalization will not change the value.
    #
    def tweet_length(text, options = {})
      options = DEFAULT_TCO_URL_LENGTHS.merge(options)

      length = text.to_nfc.unpack("U*").length

      Twitter::Extractor.extract_urls_with_indices(text) do |url, start_position, end_position|
        length += start_position - end_position
        length += url.downcase =~ /^https:\/\// ? options[:short_url_length_https] : options[:short_url_length]
      end

      length
    end

    # Check the <tt>text</tt> for any reason that it may not be valid as a Tweet. This is meant as a pre-validation
    # before posting to api.twitter.com. There are several server-side reasons for Tweets to fail but this pre-validation
    # will allow quicker feedback.
    #
    # Returns <tt>false</tt> if this <tt>text</tt> is valid. Otherwise one of the following Symbols will be returned:
    #
    #   <tt>:too_long</tt>:: if the <tt>text</tt> is too long
    #   <tt>:empty</tt>:: if the <tt>text</tt> is nil or empty
    #   <tt>:invalid_characters</tt>:: if the <tt>text</tt> contains non-Unicode or any of the disallowed Unicode characters
    def tweet_invalid?(text)
      return :empty if !text || text.empty?
      begin
        return :too_long if tweet_length(text) > MAX_LENGTH
        return :invalid_characters if Twitter::Regex::INVALID_CHARACTERS.any?{|invalid_char| text.include?(invalid_char) }
      rescue ArgumentError
        # non-Unicode value.
        return :invalid_characters
      end

      return false
    end

    def valid_tweet_text?(text)
      !tweet_invalid?(text)
    end

    def valid_username?(username)
      return false if !username || username.empty?

      extracted = Twitter::Extractor.extract_mentioned_screen_names(username)
      # Should extract the username minus the @ sign, hence the [1..-1]
      extracted.size == 1 && extracted.first == username[1..-1]
    end

    VALID_LIST_RE = /\A#{Twitter::Regex[:valid_mention_or_list]}\z/o
    def valid_list?(username_list)
      match = username_list.match(VALID_LIST_RE)
      # Must have matched and had nothing before or after
      !!(match && match[1] == "" && match[4] && !match[4].empty?)
    end

    def valid_hashtag?(hashtag)
      return false if !hashtag || hashtag.empty?

      extracted = Twitter::Extractor.extract_hashtags(hashtag)
      # Should extract the hashtag minus the # sign, hence the [1..-1]
      extracted.size == 1 && extracted.first == hashtag[1..-1]
    end

    def valid_url?(url, unicode_domains=true, require_protocol=true)
      return false if !url || url.empty?

      url_parts = url.match(Twitter::Regex[:validate_url_unencoded])
      return false unless (url_parts && url_parts.to_s == url)

      scheme, authority, path, query, fragment = url_parts.captures

      return false unless ((!require_protocol ||
                           (valid_match?(scheme, Twitter::Regex[:validate_url_scheme]) && scheme.match(/\Ahttps?\Z/i))) &&
                           valid_match?(path, Twitter::Regex[:validate_url_path]) &&
                           valid_match?(query, Twitter::Regex[:validate_url_query], true) &&
                           valid_match?(fragment, Twitter::Regex[:validate_url_fragment], true))

      return (unicode_domains && valid_match?(authority, Twitter::Regex[:validate_url_unicode_authority])) ||
             (!unicode_domains && valid_match?(authority, Twitter::Regex[:validate_url_authority]))
    end

    private

    def valid_match?(string, regex, optional=false)
      return (string && string.match(regex) && $~.to_s == string) unless optional

      !(string && (!string.match(regex) || $~.to_s != string))
    end
  end
end
