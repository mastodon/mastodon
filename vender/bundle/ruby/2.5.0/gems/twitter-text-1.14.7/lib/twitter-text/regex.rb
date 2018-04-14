# encoding: UTF-8

module Twitter
  # A collection of regular expressions for parsing Tweet text. The regular expression
  # list is frozen at load time to ensure immutability. These regular expressions are
  # used throughout the <tt>Twitter</tt> classes. Special care has been taken to make
  # sure these reular expressions work with Tweets in all languages.
  class Regex
    require 'yaml'

    REGEXEN = {} # :nodoc:

    def self.regex_range(from, to = nil) # :nodoc:
      if $RUBY_1_9
        if to
          "\\u{#{from.to_s(16).rjust(4, '0')}}-\\u{#{to.to_s(16).rjust(4, '0')}}"
        else
          "\\u{#{from.to_s(16).rjust(4, '0')}}"
        end
      else
        if to
          [from].pack('U') + '-' + [to].pack('U')
        else
          [from].pack('U')
        end
      end
    end

    TLDS = YAML.load_file(
      File.join(
        File.expand_path('../../..', __FILE__), # project root
        'lib', 'assets', 'tld_lib.yml'
      )
    )

    # Space is more than %20, U+3000 for example is the full-width space used with Kanji. Provide a short-hand
    # to access both the list of characters and a pattern suitible for use with String#split
    #  Taken from: ActiveSupport::Multibyte::Handlers::UTF8Handler::UNICODE_WHITESPACE
    UNICODE_SPACES = [
          (0x0009..0x000D).to_a,  # White_Space # Cc   [5] <control-0009>..<control-000D>
          0x0020,          # White_Space # Zs       SPACE
          0x0085,          # White_Space # Cc       <control-0085>
          0x00A0,          # White_Space # Zs       NO-BREAK SPACE
          0x1680,          # White_Space # Zs       OGHAM SPACE MARK
          0x180E,          # White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
          (0x2000..0x200A).to_a, # White_Space # Zs  [11] EN QUAD..HAIR SPACE
          0x2028,          # White_Space # Zl       LINE SEPARATOR
          0x2029,          # White_Space # Zp       PARAGRAPH SEPARATOR
          0x202F,          # White_Space # Zs       NARROW NO-BREAK SPACE
          0x205F,          # White_Space # Zs       MEDIUM MATHEMATICAL SPACE
          0x3000,          # White_Space # Zs       IDEOGRAPHIC SPACE
    ].flatten.map{|c| [c].pack('U*')}.freeze
    REGEXEN[:spaces] = /[#{UNICODE_SPACES.join('')}]/o

    # Character not allowed in Tweets
    INVALID_CHARACTERS = [
      0xFFFE, 0xFEFF, # BOM
      0xFFFF,         # Special
      0x202A, 0x202B, 0x202C, 0x202D, 0x202E # Directional change
    ].map{|cp| [cp].pack('U') }.freeze
    REGEXEN[:invalid_control_characters] = /[#{INVALID_CHARACTERS.join('')}]/o

    major, minor, _patch = RUBY_VERSION.split('.')
    if major.to_i >= 2 || major.to_i == 1 && minor.to_i >= 9 || (defined?(RUBY_ENGINE) && ["jruby", "rbx"].include?(RUBY_ENGINE))
      REGEXEN[:list_name] = /[a-zA-Z][a-zA-Z0-9_\-\u0080-\u00ff]{0,24}/
    else
      # This line barfs at compile time in Ruby 1.9, JRuby, or Rubinius.
      REGEXEN[:list_name] = eval("/[a-zA-Z][a-zA-Z0-9_\\-\x80-\xff]{0,24}/")
    end

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
          regex_range(0x1e00, 0x1eff)
    ].join('').freeze
    REGEXEN[:latin_accents] = /[#{LATIN_ACCENTS}]+/o

    RTL_CHARACTERS = [
      regex_range(0x0600,0x06FF),
      regex_range(0x0750,0x077F),
      regex_range(0x0590,0x05FF),
      regex_range(0xFE70,0xFEFF)
    ].join('').freeze

    PUNCTUATION_CHARS = '!"#$%&\'()*+,-./:;<=>?@\[\]^_\`{|}~'
    SPACE_CHARS = " \t\n\x0B\f\r"
    CTRL_CHARS = "\x00-\x1F\x7F"

    # Generated from unicode_regex/unicode_regex_groups.scala, more inclusive than Ruby's \p{L}\p{M}
    HASHTAG_LETTERS_AND_MARKS = "\\p{L}\\p{M}" +
      "\u037f\u0528-\u052f\u08a0-\u08b2\u08e4-\u08ff\u0978\u0980\u0c00\u0c34\u0c81\u0d01\u0ede\u0edf" +
      "\u10c7\u10cd\u10fd-\u10ff\u16f1-\u16f8\u17b4\u17b5\u191d\u191e\u1ab0-\u1abe\u1bab-\u1bad\u1bba-" +
      "\u1bbf\u1cf3-\u1cf6\u1cf8\u1cf9\u1de7-\u1df5\u2cf2\u2cf3\u2d27\u2d2d\u2d66\u2d67\u9fcc\ua674-" +
      "\ua67b\ua698-\ua69d\ua69f\ua792-\ua79f\ua7aa-\ua7ad\ua7b0\ua7b1\ua7f7-\ua7f9\ua9e0-\ua9ef\ua9fa-" +
      "\ua9fe\uaa7c-\uaa7f\uaae0-\uaaef\uaaf2-\uaaf6\uab30-\uab5a\uab5c-\uab5f\uab64\uab65\uf870-\uf87f" +
      "\uf882\uf884-\uf89f\uf8b8\uf8c1-\uf8d6\ufa2e\ufa2f\ufe27-\ufe2d\u{102e0}\u{1031f}\u{10350}-\u{1037a}" +
      "\u{10500}-\u{10527}\u{10530}-\u{10563}\u{10600}-\u{10736}\u{10740}-\u{10755}\u{10760}-\u{10767}" +
      "\u{10860}-\u{10876}\u{10880}-\u{1089e}\u{10980}-\u{109b7}\u{109be}\u{109bf}\u{10a80}-\u{10a9c}" +
      "\u{10ac0}-\u{10ac7}\u{10ac9}-\u{10ae6}\u{10b80}-\u{10b91}\u{1107f}\u{110d0}-\u{110e8}\u{11100}-" +
      "\u{11134}\u{11150}-\u{11173}\u{11176}\u{11180}-\u{111c4}\u{111da}\u{11200}-\u{11211}\u{11213}-" +
      "\u{11237}\u{112b0}-\u{112ea}\u{11301}-\u{11303}\u{11305}-\u{1130c}\u{1130f}\u{11310}\u{11313}-" +
      "\u{11328}\u{1132a}-\u{11330}\u{11332}\u{11333}\u{11335}-\u{11339}\u{1133c}-\u{11344}\u{11347}" +
      "\u{11348}\u{1134b}-\u{1134d}\u{11357}\u{1135d}-\u{11363}\u{11366}-\u{1136c}\u{11370}-\u{11374}" +
      "\u{11480}-\u{114c5}\u{114c7}\u{11580}-\u{115b5}\u{115b8}-\u{115c0}\u{11600}-\u{11640}\u{11644}" +
      "\u{11680}-\u{116b7}\u{118a0}-\u{118df}\u{118ff}\u{11ac0}-\u{11af8}\u{1236f}-\u{12398}\u{16a40}-" +
      "\u{16a5e}\u{16ad0}-\u{16aed}\u{16af0}-\u{16af4}\u{16b00}-\u{16b36}\u{16b40}-\u{16b43}\u{16b63}-" +
      "\u{16b77}\u{16b7d}-\u{16b8f}\u{16f00}-\u{16f44}\u{16f50}-\u{16f7e}\u{16f8f}-\u{16f9f}\u{1bc00}-" +
      "\u{1bc6a}\u{1bc70}-\u{1bc7c}\u{1bc80}-\u{1bc88}\u{1bc90}-\u{1bc99}\u{1bc9d}\u{1bc9e}\u{1e800}-" +
      "\u{1e8c4}\u{1e8d0}-\u{1e8d6}\u{1ee00}-\u{1ee03}\u{1ee05}-\u{1ee1f}\u{1ee21}\u{1ee22}\u{1ee24}" +
      "\u{1ee27}\u{1ee29}-\u{1ee32}\u{1ee34}-\u{1ee37}\u{1ee39}\u{1ee3b}\u{1ee42}\u{1ee47}\u{1ee49}" +
      "\u{1ee4b}\u{1ee4d}-\u{1ee4f}\u{1ee51}\u{1ee52}\u{1ee54}\u{1ee57}\u{1ee59}\u{1ee5b}\u{1ee5d}\u{1ee5f}" +
      "\u{1ee61}\u{1ee62}\u{1ee64}\u{1ee67}-\u{1ee6a}\u{1ee6c}-\u{1ee72}\u{1ee74}-\u{1ee77}\u{1ee79}-" +
      "\u{1ee7c}\u{1ee7e}\u{1ee80}-\u{1ee89}\u{1ee8b}-\u{1ee9b}\u{1eea1}-\u{1eea3}\u{1eea5}-\u{1eea9}" +
      "\u{1eeab}-\u{1eebb}"

    # Generated from unicode_regex/unicode_regex_groups.scala, more inclusive than Ruby's \p{Nd}
    HASHTAG_NUMERALS = "\\p{Nd}" +
      "\u0de6-\u0def\ua9f0-\ua9f9\u{110f0}-\u{110f9}\u{11136}-\u{1113f}\u{111d0}-\u{111d9}\u{112f0}-" +
      "\u{112f9}\u{114d0}-\u{114d9}\u{11650}-\u{11659}\u{116c0}-\u{116c9}\u{118e0}-\u{118e9}\u{16a60}-" +
      "\u{16a69}\u{16b50}-\u{16b59}"

    HASHTAG_SPECIAL_CHARS = "_\u200c\u200d\ua67e\u05be\u05f3\u05f4\uff5e\u301c\u309b\u309c\u30a0\u30fb\u3003\u0f0b\u0f0c\u00b7"

    HASHTAG_LETTERS_NUMERALS = "#{HASHTAG_LETTERS_AND_MARKS}#{HASHTAG_NUMERALS}#{HASHTAG_SPECIAL_CHARS}"
    HASHTAG_LETTERS_NUMERALS_SET = "[#{HASHTAG_LETTERS_NUMERALS}]"
    HASHTAG_LETTERS_SET = "[#{HASHTAG_LETTERS_AND_MARKS}]"

    HASHTAG = /(\A|\ufe0e|\ufe0f|[^&#{HASHTAG_LETTERS_NUMERALS}])(#|＃)(?!\ufe0f|\u20e3)(#{HASHTAG_LETTERS_NUMERALS_SET}*#{HASHTAG_LETTERS_SET}#{HASHTAG_LETTERS_NUMERALS_SET}*)/io

    REGEXEN[:valid_hashtag] = /#{HASHTAG}/io
    # Used in Extractor for final filtering
    REGEXEN[:end_hashtag_match] = /\A(?:[#＃]|:\/\/)/o

    REGEXEN[:valid_mention_preceding_chars] = /(?:[^a-zA-Z0-9_!#\$%&*@＠]|^|(?:^|[^a-zA-Z0-9_+~.-])[rR][tT]:?)/o
    REGEXEN[:at_signs] = /[@＠]/
    REGEXEN[:valid_mention_or_list] = /
      (#{REGEXEN[:valid_mention_preceding_chars]})  # $1: Preceeding character
      (#{REGEXEN[:at_signs]})                       # $2: At mark
      ([a-zA-Z0-9_]{1,20})                          # $3: Screen name
      (\/[a-zA-Z][a-zA-Z0-9_\-]{0,24})?             # $4: List (optional)
    /ox
    REGEXEN[:valid_reply] = /^(?:#{REGEXEN[:spaces]})*#{REGEXEN[:at_signs]}([a-zA-Z0-9_]{1,20})/o
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

    # This is used in Extractor for stricter t.co URL extraction
    REGEXEN[:valid_tco_url] = /^https?:\/\/t\.co\/[a-z0-9]+/i

    # This is used in Extractor to filter out unwanted URLs.
    REGEXEN[:invalid_short_domain] = /\A#{REGEXEN[:valid_domain_name]}#{REGEXEN[:valid_ccTLD]}\Z/io
    REGEXEN[:valid_special_short_domain] = /\A#{REGEXEN[:valid_domain_name]}#{REGEXEN[:valid_special_cctld]}\Z/io

    REGEXEN[:valid_port_number] = /[0-9]+/

    REGEXEN[:valid_general_url_path_chars] = /[a-z\p{Cyrillic}0-9!\*';:=\+\,\.\$\/%#\[\]\-_~&\|@#{LATIN_ACCENTS}]/io
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
    REGEXEN[:valid_url_path_ending_chars] = /[a-z\p{Cyrillic}0-9=_#\/\+\-#{LATIN_ACCENTS}]|(?:#{REGEXEN[:valid_url_balanced_parens]})/io
    REGEXEN[:valid_url_path] = /(?:
      (?:
        #{REGEXEN[:valid_general_url_path_chars]}*
        (?:#{REGEXEN[:valid_url_balanced_parens]} #{REGEXEN[:valid_general_url_path_chars]}*)*
        #{REGEXEN[:valid_url_path_ending_chars]}
      )|(?:#{REGEXEN[:valid_general_url_path_chars]}+\/)
    )/iox

    REGEXEN[:valid_url_query_chars] = /[a-z0-9!?\*'\(\);:&=\+\$\/%#\[\]\-_\.,~|@]/i
    REGEXEN[:valid_url_query_ending_chars] = /[a-z0-9_&=#\/\-]/i
    REGEXEN[:valid_url] = %r{
      (                                                                                     #   $1 total match
        (#{REGEXEN[:valid_url_preceding_chars]})                                            #   $2 Preceeding chracter
        (                                                                                   #   $3 URL
          (https?:\/\/)?                                                                    #   $4 Protocol (optional)
          (#{REGEXEN[:valid_domain]})                                                       #   $5 Domain(s)
          (?::(#{REGEXEN[:valid_port_number]}))?                                            #   $6 Port number (optional)
          (/#{REGEXEN[:valid_url_path]}*)?                                                  #   $7 URL Path and anchor
          (\?#{REGEXEN[:valid_url_query_chars]}*#{REGEXEN[:valid_url_query_ending_chars]})? #   $8 Query String
        )
      )
    }iox

    REGEXEN[:cashtag] = /[a-z]{1,6}(?:[._][a-z]{1,2})?/i
    REGEXEN[:valid_cashtag] = /(^|#{REGEXEN[:spaces]})(\$)(#{REGEXEN[:cashtag]})(?=$|\s|[#{PUNCTUATION_CHARS}])/i

    # These URL validation pattern strings are based on the ABNF from RFC 3986
    REGEXEN[:validate_url_unreserved] = /[a-z\p{Cyrillic}0-9\-._~]/i
    REGEXEN[:validate_url_pct_encoded] = /(?:%[0-9a-f]{2})/i
    REGEXEN[:validate_url_sub_delims] = /[!$&'()*+,;=]/i
    REGEXEN[:validate_url_pchar] = /(?:
      #{REGEXEN[:validate_url_unreserved]}|
      #{REGEXEN[:validate_url_pct_encoded]}|
      #{REGEXEN[:validate_url_sub_delims]}|
      [:\|@]
    )/iox

    REGEXEN[:validate_url_scheme] = /(?:[a-z][a-z0-9+\-.]*)/i
    REGEXEN[:validate_url_userinfo] = /(?:
      #{REGEXEN[:validate_url_unreserved]}|
      #{REGEXEN[:validate_url_pct_encoded]}|
      #{REGEXEN[:validate_url_sub_delims]}|
      :
    )*/iox

    REGEXEN[:validate_url_dec_octet] = /(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9]{2})|(?:2[0-4][0-9])|(?:25[0-5]))/i
    REGEXEN[:validate_url_ipv4] =
      /(?:#{REGEXEN[:validate_url_dec_octet]}(?:\.#{REGEXEN[:validate_url_dec_octet]}){3})/iox

    # Punting on real IPv6 validation for now
    REGEXEN[:validate_url_ipv6] = /(?:\[[a-f0-9:\.]+\])/i

    # Also punting on IPvFuture for now
    REGEXEN[:validate_url_ip] = /(?:
      #{REGEXEN[:validate_url_ipv4]}|
      #{REGEXEN[:validate_url_ipv6]}
    )/iox

    # This is more strict than the rfc specifies
    REGEXEN[:validate_url_subdomain_segment] = /(?:[a-z0-9](?:[a-z0-9_\-]*[a-z0-9])?)/i
    REGEXEN[:validate_url_domain_segment] = /(?:[a-z0-9](?:[a-z0-9\-]*[a-z0-9])?)/i
    REGEXEN[:validate_url_domain_tld] = /(?:[a-z](?:[a-z0-9\-]*[a-z0-9])?)/i
    REGEXEN[:validate_url_domain] = /(?:(?:#{REGEXEN[:validate_url_subdomain_segment]}\.)*
                                     (?:#{REGEXEN[:validate_url_domain_segment]}\.)
                                     #{REGEXEN[:validate_url_domain_tld]})/iox

    REGEXEN[:validate_url_host] = /(?:
      #{REGEXEN[:validate_url_ip]}|
      #{REGEXEN[:validate_url_domain]}
    )/iox

    # Unencoded internationalized domains - this doesn't check for invalid UTF-8 sequences
    REGEXEN[:validate_url_unicode_subdomain_segment] =
      /(?:(?:[a-z0-9]|[^\x00-\x7f])(?:(?:[a-z0-9_\-]|[^\x00-\x7f])*(?:[a-z0-9]|[^\x00-\x7f]))?)/ix
    REGEXEN[:validate_url_unicode_domain_segment] =
      /(?:(?:[a-z0-9]|[^\x00-\x7f])(?:(?:[a-z0-9\-]|[^\x00-\x7f])*(?:[a-z0-9]|[^\x00-\x7f]))?)/ix
    REGEXEN[:validate_url_unicode_domain_tld] =
      /(?:(?:[a-z]|[^\x00-\x7f])(?:(?:[a-z0-9\-]|[^\x00-\x7f])*(?:[a-z0-9]|[^\x00-\x7f]))?)/ix
    REGEXEN[:validate_url_unicode_domain] = /(?:(?:#{REGEXEN[:validate_url_unicode_subdomain_segment]}\.)*
                                             (?:#{REGEXEN[:validate_url_unicode_domain_segment]}\.)
                                             #{REGEXEN[:validate_url_unicode_domain_tld]})/iox

    REGEXEN[:validate_url_unicode_host] = /(?:
      #{REGEXEN[:validate_url_ip]}|
      #{REGEXEN[:validate_url_unicode_domain]}
    )/iox

    REGEXEN[:validate_url_port] = /[0-9]{1,5}/

    REGEXEN[:validate_url_unicode_authority] = %r{
      (?:(#{REGEXEN[:validate_url_userinfo]})@)?     #  $1 userinfo
      (#{REGEXEN[:validate_url_unicode_host]})       #  $2 host
      (?::(#{REGEXEN[:validate_url_port]}))?         #  $3 port
    }iox

    REGEXEN[:validate_url_authority] = %r{
      (?:(#{REGEXEN[:validate_url_userinfo]})@)?     #  $1 userinfo
      (#{REGEXEN[:validate_url_host]})               #  $2 host
      (?::(#{REGEXEN[:validate_url_port]}))?         #  $3 port
    }iox

    REGEXEN[:validate_url_path] = %r{(/#{REGEXEN[:validate_url_pchar]}*)*}i
    REGEXEN[:validate_url_query] = %r{(#{REGEXEN[:validate_url_pchar]}|/|\?)*}i
    REGEXEN[:validate_url_fragment] = %r{(#{REGEXEN[:validate_url_pchar]}|/|\?)*}i

    # Modified version of RFC 3986 Appendix B
    REGEXEN[:validate_url_unencoded] = %r{
      \A                                #  Full URL
      (?:
        ([^:/?#]+)://                  #  $1 Scheme
      )?
      ([^/?#]*)                        #  $2 Authority
      ([^?#]*)                         #  $3 Path
      (?:
        \?([^#]*)                      #  $4 Query
      )?
      (?:
        \#(.*)                         #  $5 Fragment
      )?\Z
    }ix

    REGEXEN[:rtl_chars] = /[#{RTL_CHARACTERS}]/io

    REGEXEN.each_pair{|k,v| v.freeze }

    # Return the regular expression for a given <tt>key</tt>. If the <tt>key</tt>
    # is not a known symbol a <tt>nil</tt> will be returned.
    def self.[](key)
      REGEXEN[key]
    end
  end
end
