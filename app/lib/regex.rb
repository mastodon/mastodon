# frozen_string_literal: true

# Adopted rb/lib/twitter-text/extractor.rb from twitter-text.
# Please contribute new changes of this file to the upstream if they are not specific to Mastodon.

# A collection of regular expressions for parsing Toot text. The regular expression
# list is frozen at load time to ensure immutability. These regular expressions are
# used throughout Mastodon. Special care has been taken to make sure these
# reular expressions work with Toots in all languages.
module Regex
  # Use Regex.[] instead when referring from other classes and modules.
  REGEXEN = {} # rubocop:disable Style/MutableConstant

  def self.regex_range(from, to = nil)
    if to
      [from].pack('U') + '-' + [to].pack('U')
    else
      [from].pack('U')
    end
  end

  TLDS = YAML.load_file(Rails.root.join('app', 'assets', 'tld_lib.yml'))

  # Space is more than %20, U+3000 for example is the full-width space used with Kanji. Provide a short-hand
  # to access both the list of characters and a pattern suitible for use with String#split
  #  Taken from: ActiveSupport::Multibyte::Handlers::UTF8Handler::UNICODE_WHITESPACE
  #              It was removed at commit 293cdecee309744d4e75e1b9f5bdd8d523d27c2e.
  UNICODE_SPACES = [
    (0x0009..0x000D).to_a,  # White_Space # Cc   [5] <control-0009>..<control-000D>
    0x0020,                 # White_Space # Zs       SPACE
    0x0085,                 # White_Space # Cc       <control-0085>
    0x00A0,                 # White_Space # Zs       NO-BREAK SPACE
    0x1680,                 # White_Space # Zs       OGHAM SPACE MARK
    0x180E,                 # White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
    (0x2000..0x200A).to_a,  # White_Space # Zs  [11] EN QUAD..HAIR SPACE
    0x2028,                 # White_Space # Zl       LINE SEPARATOR
    0x2029,                 # White_Space # Zp       PARAGRAPH SEPARATOR
    0x202F,                 # White_Space # Zs       NARROW NO-BREAK SPACE
    0x205F,                 # White_Space # Zs       MEDIUM MATHEMATICAL SPACE
    0x3000,                 # White_Space # Zs       IDEOGRAPHIC SPACE
  ].flatten.map { |c| [c].pack('U*') }.freeze

  # Character not allowed in Tweets
  INVALID_CHARACTERS = [
    0xFFFE, 0xFEFF, # BOM
    0xFFFF,         # Special
    0x202A, 0x202B, 0x202C, 0x202D, 0x202E # Directional change
  ].map { |cp| [cp].pack('U') }.freeze

  # Latin accented characters
  # Excludes 0xd7 from the range (the multiplication sign, confusable with "x").
  # Also excludes 0xf7, the division sign
  LATIN_ACCENTS = [
    regex_range(0xc0, 0xd6),
    regex_range(0xd8, 0xf6),
    regex_range(0xf8, 0xff),
    regex_range(0x0100, 0x024f),
    regex_range(0x0253, 0x0254),
    regex_range(0x0256, 0x0257),
    regex_range(0x0259),
    regex_range(0x025b),
    regex_range(0x0263),
    regex_range(0x0268),
    regex_range(0x026f),
    regex_range(0x0272),
    regex_range(0x0289),
    regex_range(0x028b),
    regex_range(0x02bb),
    regex_range(0x0300, 0x036f),
    regex_range(0x1e00, 0x1eff),
  ].join('').freeze
  REGEXEN[:latin_accents] = /[#{LATIN_ACCENTS}]+/o

  PUNCTUATION_CHARS = '!"#$%&\'()*+,-./:;<=>?@\[\]^_\`{|}~'
  SPACE_CHARS = " \t\n\x0B\f\r"
  CTRL_CHARS = "\x00-\x1F\x7F"

  REGEXEN[:valid_hashtag] = /(?:^|[^\/\)\w])#(#{Tag::HASHTAG_NAME_RE})/i
  # Used in Extractor for final filtering
  REGEXEN[:end_hashtag_match] = /\A:\/\//

  REGEXEN[:at_signs] = /[@＠]/
  REGEXEN[:valid_mention] = /(?:^|[^\/[:word:]])@(([a-z0-9_]+)(?:@[a-z0-9\.\-]+[a-z0-9]+)?)/i
  # Used in Extractor for final filtering
  REGEXEN[:end_mention_match] = /\A(?:#{REGEXEN[:at_signs]}|#{REGEXEN[:latin_accents]}|:\/\/)/o

  # URL related hash regex collection
  REGEXEN[:valid_url_preceding_chars] = /(?:[^A-Z0-9@＠$#＃#{INVALID_CHARACTERS.join('')}]|^)/io
  REGEXEN[:invalid_url_without_protocol_preceding_chars] = /[-_.\/]$/
  DOMAIN_VALID_CHARS = "[^#{PUNCTUATION_CHARS}#{SPACE_CHARS}#{CTRL_CHARS}#{INVALID_CHARACTERS.join('')}#{UNICODE_SPACES.join('')}]"
  REGEXEN[:valid_subdomain] = /(?:(?:#{DOMAIN_VALID_CHARS}(?:[_-]|#{DOMAIN_VALID_CHARS})*)?#{DOMAIN_VALID_CHARS}\.)/io
  REGEXEN[:valid_domain_name] = /(?:(?:#{DOMAIN_VALID_CHARS}(?:[-]|#{DOMAIN_VALID_CHARS})*)?#{DOMAIN_VALID_CHARS}\.)/io

  REGEXEN[:valid_gTLD] = %r{
    (?:
      (?:#{TLDS['generic'].join('|')})
      (?=[^0-9a-z@]|$)
    )
  }ix

  REGEXEN[:valid_ccTLD] = %r{
    (?:
      (?:#{TLDS['country'].join('|')})
      (?=[^0-9a-z@]|$)
    )
  }ix
  REGEXEN[:valid_punycode] = /(?:xn--[0-9a-z]+)/i

  REGEXEN[:valid_special_cctld] = %r{
    (?:
      (?:co|tv)
      (?=[^0-9a-z@]|$)
    )
  }ix

  REGEXEN[:valid_domain] = /(?:
    #{REGEXEN[:valid_subdomain]}*#{REGEXEN[:valid_domain_name]}
    (?:#{REGEXEN[:valid_gTLD]}|#{REGEXEN[:valid_ccTLD]}|#{REGEXEN[:valid_punycode]})
  )/iox

  # This is used in Extractor
  REGEXEN[:valid_ascii_domain] = /
    (?:(?:[A-Za-z0-9\-_]|#{REGEXEN[:latin_accents]})+\.)+
    (?:#{REGEXEN[:valid_gTLD]}|#{REGEXEN[:valid_ccTLD]}|#{REGEXEN[:valid_punycode]})
  /iox

  # This is used in Extractor to filter out unwanted URLs.
  REGEXEN[:invalid_short_domain] = /\A#{REGEXEN[:valid_domain_name]}#{REGEXEN[:valid_ccTLD]}\Z/io
  REGEXEN[:valid_special_short_domain] = /\A#{REGEXEN[:valid_domain_name]}#{REGEXEN[:valid_special_cctld]}\Z/io

  REGEXEN[:valid_port_number] = /[0-9]+/

  REGEXEN[:valid_general_url_path_chars] = /[^\p{White_Space}\(\)\?]/iou
  # Allow URL paths to contain up to two nested levels of balanced parens
  #  1. Used in Wikipedia URLs like /Primer_(film)
  #  2. Used in IIS sessions like /S(dfd346)/
  #  3. Used in Rdio URLs like /track/We_Up_(Album_Version_(Edited))/
  REGEXEN[:valid_url_balanced_parens] = /
    \(
      (?:
        #{REGEXEN[:valid_general_url_path_chars]}+
        |
        # allow one nested level of balanced parentheses
        (?:
          #{REGEXEN[:valid_general_url_path_chars]}*
          \(
            #{REGEXEN[:valid_general_url_path_chars]}+
          \)
          #{REGEXEN[:valid_general_url_path_chars]}*
        )
      )
    \)
  /iox
  # Valid end-of-path chracters (so /foo. does not gobble the period).
  #   1. Allow =&# for empty URL parameters and other URL-join artifacts
  REGEXEN[:valid_url_path_ending_chars] = /[^\p{White_Space}\(\)\?!\*';:=\,\.\$%\[\]\p{Pd}~&\|@]|(?:#{REGEXEN[:valid_url_balanced_parens]})/iou

  REGEXEN[:valid_url_path] = /(?:
    (?:
      #{REGEXEN[:valid_general_url_path_chars]}*
      (?:#{REGEXEN[:valid_url_balanced_parens]} #{REGEXEN[:valid_general_url_path_chars]}*)*
      #{REGEXEN[:valid_url_path_ending_chars]}
    )|(?:#{REGEXEN[:valid_general_url_path_chars]}+\/)
  )/iox

  REGEXEN[:valid_url_query_chars] = /[a-z0-9!?\*'\(\);:&=\+\$\/%#\[\]\-_\.,~|@]/i
  REGEXEN[:valid_url_query_ending_chars] = /[a-z0-9_&=#\/\-]/i
  REGEXEN[:valid_url_body] = %r{
    (                                                                                   #   $1 URL
      (https?:\/\/)?                                                                    #   $2 Protocol (optional)
      (#{REGEXEN[:valid_domain]})                                                       #   $3 Domain(s)
      (?::(#{REGEXEN[:valid_port_number]}))?                                            #   $4 Port number (optional)
      (/#{REGEXEN[:valid_url_path]}*)?                                                  #   $5 URL Path and anchor
      (\?#{REGEXEN[:valid_url_query_chars]}*#{REGEXEN[:valid_url_query_ending_chars]})? #   $6 Query String
    )
  }iox
  REGEXEN[:valid_url] = %r{
    (                                                                                   #   $1 total match
      (#{REGEXEN[:valid_url_preceding_chars]})                                          #   $2 Preceeding chracter
      #{REGEXEN[:valid_url_body]}
    )
  }iox

  REGEXEN.each_value(&:freeze)

  # Return the regular expression for a given <tt>key</tt>. If the <tt>key</tt>
  # is not a known symbol a <tt>nil</tt> will be returned.
  def self.[](key)
    REGEXEN[key]
  end
end
