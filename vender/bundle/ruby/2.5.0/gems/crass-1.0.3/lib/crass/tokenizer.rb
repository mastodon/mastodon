# encoding: utf-8
require_relative 'scanner'

module Crass

  # Tokenizes a CSS string.
  #
  # 4. http://dev.w3.org/csswg/css-syntax/#tokenization
  class Tokenizer
    RE_COMMENT_CLOSE   = /\*\//
    RE_DIGIT           = /[0-9]+/
    RE_ESCAPE          = /\\[^\n]/
    RE_HEX             = /[0-9A-Fa-f]{1,6}/
    RE_NAME            = /[0-9A-Za-z_\u0080-\u{10ffff}-]+/
    RE_NAME_START      = /[A-Za-z_\u0080-\u{10ffff}]+/
    RE_NON_PRINTABLE   = /[\u0000-\u0008\u000b\u000e-\u001f\u007f]+/
    RE_NUMBER_DECIMAL  = /\.[0-9]+/
    RE_NUMBER_EXPONENT = /[Ee][+-]?[0-9]+/
    RE_NUMBER_SIGN     = /[+-]/

    RE_NUMBER_STR = /\A
      (?<sign> [+-]?)
      (?<integer> [0-9]*)
      (?:\.
        (?<fractional> [0-9]*)
      )?
      (?:[Ee]
        (?<exponent_sign> [+-]?)
        (?<exponent> [0-9]*)
      )?
    \z/x

    RE_QUOTED_URL_START    = /\A[\n\u0009\u0020]?["']/
    RE_UNICODE_RANGE_START = /\+(?:[0-9A-Fa-f]|\?)/
    RE_UNICODE_RANGE_END   = /-[0-9A-Fa-f]/
    RE_WHITESPACE          = /[\n\u0009\u0020]+/
    RE_WHITESPACE_ANCHORED = /\A[\n\u0009\u0020]+\z/

    # -- Class Methods ---------------------------------------------------------

    # Tokenizes the given _input_ as a CSS string and returns an array of
    # tokens.
    #
    # See {#initialize} for _options_.
    def self.tokenize(input, options = {})
      Tokenizer.new(input, options).tokenize
    end

    # -- Instance Methods ------------------------------------------------------

    # Initializes a new Tokenizer.
    #
    # Options:
    #
    #   * **:preserve_comments** - If `true`, comments will be preserved as
    #     `:comment` tokens.
    #
    #   * **:preserve_hacks** - If `true`, certain non-standard browser hacks
    #     such as the IE "*" hack will be preserved even though they violate
    #     CSS 3 syntax rules.
    #
    def initialize(input, options = {})
      @s       = Scanner.new(preprocess(input))
      @options = options
    end

    # Consumes a token and returns the token that was consumed.
    #
    # 4.3.1. http://dev.w3.org/csswg/css-syntax/#consume-a-token
    def consume
      return nil if @s.eos?

      @s.mark

      # Consume comments.
      if comment_token = consume_comments
        if @options[:preserve_comments]
          return comment_token
        else
          return consume
        end
      end

      # Consume whitespace.
      return create_token(:whitespace) if @s.scan(RE_WHITESPACE)

      char = @s.consume

      case char.to_sym
      when :'"'
        consume_string

      when :'#'
        if @s.peek =~ RE_NAME || valid_escape?(@s.peek(2))
          create_token(:hash,
            :type  => start_identifier?(@s.peek(3)) ? :id : :unrestricted,
            :value => consume_name)
        else
          create_token(:delim, :value => char)
        end

      when :'$'
        if @s.peek == '='
          @s.consume
          create_token(:suffix_match)
        else
          create_token(:delim, :value => char)
        end

      when :"'"
        consume_string

      when :'('
        create_token(:'(')

      when :')'
        create_token(:')')

      when :*
        if @s.peek == '='
          @s.consume
          create_token(:substring_match)

        # Non-standard: Preserve the IE * hack.
        elsif @options[:preserve_hacks] && @s.peek =~ RE_NAME_START
          @s.reconsume
          consume_ident

        else
          create_token(:delim, :value => char)
        end

      when :+
        if start_number?
          @s.reconsume
          consume_numeric
        else
          create_token(:delim, :value => char)
        end

      when :','
        create_token(:comma)

      when :-
        nextTwoChars   = @s.peek(2)
        nextThreeChars = char + nextTwoChars

        if start_number?(nextThreeChars)
          @s.reconsume
          consume_numeric
        elsif nextTwoChars == '->'
          @s.consume
          @s.consume
          create_token(:cdc)
        elsif start_identifier?(nextThreeChars)
          @s.reconsume
          consume_ident
        else
          create_token(:delim, :value => char)
        end

      when :'.'
        if start_number?
          @s.reconsume
          consume_numeric
        else
          create_token(:delim, :value => char)
        end

      when :':'
        create_token(:colon)

      when :';'
        create_token(:semicolon)

      when :<
        if @s.peek(3) == '!--'
          @s.consume
          @s.consume
          @s.consume

          create_token(:cdo)
        else
          create_token(:delim, :value => char)
        end

      when :'@'
        if start_identifier?(@s.peek(3))
          create_token(:at_keyword, :value => consume_name)
        else
          create_token(:delim, :value => char)
        end

      when :'['
        create_token(:'[')

      when :'\\'
        if valid_escape?
          @s.reconsume
          consume_ident
        else
          # Parse error.
          create_token(:delim,
            :error => true,
            :value => char)
        end

      when :']'
        create_token(:']')

      when :'^'
        if @s.peek == '='
          @s.consume
          create_token(:prefix_match)
        else
          create_token(:delim, :value => char)
        end

      when :'{'
        create_token(:'{')

      when :'}'
        create_token(:'}')

      when :U, :u
        if @s.peek(2) =~ RE_UNICODE_RANGE_START
          @s.consume
          consume_unicode_range
        else
          @s.reconsume
          consume_ident
        end

      when :|
        case @s.peek
        when '='
          @s.consume
          create_token(:dash_match)

        when '|'
          @s.consume
          create_token(:column)

        else
          create_token(:delim, :value => char)
        end

      when :~
        if @s.peek == '='
          @s.consume
          create_token(:include_match)
        else
          create_token(:delim, :value => char)
        end

      else
        case char
        when RE_DIGIT
          @s.reconsume
          consume_numeric

        when RE_NAME_START
          @s.reconsume
          consume_ident

        else
          create_token(:delim, :value => char)
        end
      end
    end

    # Consumes the remnants of a bad URL and returns the consumed text.
    #
    # 4.3.15. http://dev.w3.org/csswg/css-syntax/#consume-the-remnants-of-a-bad-url
    def consume_bad_url
      text = String.new

      until @s.eos?
        if valid_escape?
          text << consume_escaped
        elsif valid_escape?(@s.peek(2))
          @s.consume
          text << consume_escaped
        else
          char = @s.consume

          if char == ')'
            break
          else
            text << char
          end
        end
      end

      text
    end

    # Consumes comments and returns them, or `nil` if no comments were consumed.
    #
    # 4.3.2. http://dev.w3.org/csswg/css-syntax/#consume-comments
    def consume_comments
      if @s.peek(2) == '/*'
        @s.consume
        @s.consume

        if text = @s.scan_until(RE_COMMENT_CLOSE)
          text.slice!(-2, 2)
        else
          # Parse error.
          text = @s.consume_rest
        end

        return create_token(:comment, :value => text)
      end

      nil
    end

    # Consumes an escaped code point and returns its unescaped value.
    #
    # This method assumes that the `\` has already been consumed, and that the
    # next character in the input has already been verified not to be a newline
    # or EOF.
    #
    # 4.3.8. http://dev.w3.org/csswg/css-syntax/#consume-an-escaped-code-point
    def consume_escaped
      return "\ufffd" if @s.eos?

      if hex_str = @s.scan(RE_HEX)
        @s.consume if @s.peek =~ RE_WHITESPACE

        codepoint = hex_str.hex

        if codepoint == 0 ||
            codepoint.between?(0xD800, 0xDFFF) ||
            codepoint > 0x10FFFF

          return "\ufffd"
        else
          return codepoint.chr(Encoding::UTF_8)
        end
      end

      @s.consume
    end

    # Consumes an ident-like token and returns it.
    #
    # 4.3.4. http://dev.w3.org/csswg/css-syntax/#consume-an-ident-like-token
    def consume_ident
      value = consume_name

      if @s.peek == '('
        @s.consume

        if value.downcase == 'url'
          @s.consume while @s.peek(2) =~ RE_WHITESPACE_ANCHORED

          if @s.peek(2) =~ RE_QUOTED_URL_START
            create_token(:function, :value => value)
          else
            consume_url
          end
        else
          create_token(:function, :value => value)
        end
      else
        create_token(:ident, :value => value)
      end
    end

    # Consumes a name and returns it.
    #
    # 4.3.12. http://dev.w3.org/csswg/css-syntax/#consume-a-name
    def consume_name
      result = String.new

      until @s.eos?
        if match = @s.scan(RE_NAME)
          result << match
          next
        end

        char = @s.consume

        if valid_escape?
          result << consume_escaped

        # Non-standard: IE * hack
        elsif char == '*' && @options[:preserve_hacks]
          result << @s.consume

        else
          @s.reconsume
          return result
        end
      end

      result
    end

    # Consumes a number and returns a 3-element array containing the number's
    # original representation, its numeric value, and its type (either
    # `:integer` or `:number`).
    #
    # 4.3.13. http://dev.w3.org/csswg/css-syntax/#consume-a-number
    def consume_number
      repr = String.new
      type = :integer

      repr << @s.consume if @s.peek =~ RE_NUMBER_SIGN
      repr << (@s.scan(RE_DIGIT) || '')

      if match = @s.scan(RE_NUMBER_DECIMAL)
        repr << match
        type = :number
      end

      if match = @s.scan(RE_NUMBER_EXPONENT)
        repr << match
        type = :number
      end

      [repr, convert_string_to_number(repr), type]
    end

    # Consumes a numeric token and returns it.
    #
    # 4.3.3. http://dev.w3.org/csswg/css-syntax/#consume-a-numeric-token
    def consume_numeric
      number = consume_number

      if start_identifier?(@s.peek(3))
        create_token(:dimension,
          :repr  => number[0],
          :type  => number[2],
          :unit  => consume_name,
          :value => number[1])

      elsif @s.peek == '%'
        @s.consume

        create_token(:percentage,
          :repr  => number[0],
          :type  => number[2],
          :value => number[1])

      else
        create_token(:number,
          :repr  => number[0],
          :type  => number[2],
          :value => number[1])
      end
    end

    # Consumes a string token that ends at the given character, and returns the
    # token.
    #
    # 4.3.5. http://dev.w3.org/csswg/css-syntax/#consume-a-string-token
    def consume_string(ending = nil)
      ending = @s.current if ending.nil?
      value  = String.new

      until @s.eos?
        case char = @s.consume
        when ending
          break

        when "\n"
          # Parse error.
          @s.reconsume
          return create_token(:bad_string,
            :error => true,
            :value => value)

        when '\\'
          case @s.peek
          when ''
            # End of the input, so do nothing.
            next

          when "\n"
            @s.consume

          else
            value << consume_escaped
          end

        else
          value << char
        end
      end

      create_token(:string, :value => value)
    end

    # Consumes a Unicode range token and returns it. Assumes the initial "u+" or
    # "U+" has already been consumed.
    #
    # 4.3.7. http://dev.w3.org/csswg/css-syntax/#consume-a-unicode-range-token
    def consume_unicode_range
      value = @s.scan(RE_HEX) || String.new

      while value.length < 6
        break unless @s.peek == '?'
        value << @s.consume
      end

      range = {}

      if value.include?('?')
        range[:start] = value.gsub('?', '0').hex
        range[:end]   = value.gsub('?', 'F').hex
        return create_token(:unicode_range, range)
      end

      range[:start] = value.hex

      if @s.peek(2) =~ RE_UNICODE_RANGE_END
        @s.consume
        range[:end] = (@s.scan(RE_HEX) || '').hex
      else
        range[:end] = range[:start]
      end

      create_token(:unicode_range, range)
    end

    # Consumes a URL token and returns it. Assumes the original "url(" has
    # already been consumed.
    #
    # 4.3.6. http://dev.w3.org/csswg/css-syntax/#consume-a-url-token
    def consume_url
      value = String.new

      @s.scan(RE_WHITESPACE)

      until @s.eos?
        case char = @s.consume
          when ')'
            break

          when RE_WHITESPACE
            @s.scan(RE_WHITESPACE)

            if @s.eos? || @s.peek == ')'
              @s.consume
              break
            else
              return create_token(:bad_url, :value => value + consume_bad_url)
            end

          when '"', "'", '(', RE_NON_PRINTABLE
            # Parse error.
            return create_token(:bad_url,
              :error => true,
              :value => value + consume_bad_url)

          when '\\'
            if valid_escape?
              value << consume_escaped
            else
              # Parse error.
              return create_token(:bad_url,
                :error => true,
                :value => value + consume_bad_url
              )
            end

          else
            value << char
        end
      end

      create_token(:url, :value => value)
    end

    # Converts a valid CSS number string into a number and returns the number.
    #
    # 4.3.14. http://dev.w3.org/csswg/css-syntax/#convert-a-string-to-a-number
    def convert_string_to_number(str)
      matches = RE_NUMBER_STR.match(str)

      s = matches[:sign] == '-' ? -1 : 1
      i = matches[:integer].to_i
      f = matches[:fractional].to_i
      d = matches[:fractional] ? matches[:fractional].length : 0
      t = matches[:exponent_sign] == '-' ? -1 : 1
      e = matches[:exponent].to_i

      # I know this looks nutty, but it's exactly what's defined in the spec,
      # and it works.
      s * (i + f * 10**-d) * 10**(t * e)
    end

    # Creates and returns a new token with the given _properties_.
    def create_token(type, properties = {})
      {
        :node => type,
        :pos  => @s.marker,
        :raw  => @s.marked
      }.merge!(properties)
    end

    # Preprocesses _input_ to prepare it for the tokenizer.
    #
    # 3.3. http://dev.w3.org/csswg/css-syntax/#input-preprocessing
    def preprocess(input)
      input = input.to_s.encode('UTF-8',
        :invalid => :replace,
        :undef   => :replace)

      input.gsub!(/(?:\r\n|[\r\f])/, "\n")
      input.gsub!("\u0000", "\ufffd")
      input
    end

    # Returns `true` if the given three-character _text_ would start an
    # identifier. If _text_ is `nil`, the current and next two characters in the
    # input stream will be checked, but will not be consumed.
    #
    # 4.3.10. http://dev.w3.org/csswg/css-syntax/#would-start-an-identifier
    def start_identifier?(text = nil)
      text = @s.current + @s.peek(2) if text.nil?

      case text[0]
      when '-'
        nextChar = text[1]
        !!(nextChar == '-' || nextChar =~ RE_NAME_START || valid_escape?(text[1, 2]))

      when RE_NAME_START
        true

      when '\\'
        valid_escape?(text[0, 2])

      else
        false
      end
    end

    # Returns `true` if the given three-character _text_ would start a number.
    # If _text_ is `nil`, the current and next two characters in the input
    # stream will be checked, but will not be consumed.
    #
    # 4.3.11. http://dev.w3.org/csswg/css-syntax/#starts-with-a-number
    def start_number?(text = nil)
      text = @s.current + @s.peek(2) if text.nil?

      case text[0]
      when '+', '-'
        !!(text[1] =~ RE_DIGIT || (text[1] == '.' && text[2] =~ RE_DIGIT))

      when '.'
        !!(text[1] =~ RE_DIGIT)

      when RE_DIGIT
        true

      else
        false
      end
    end

    # Tokenizes the input stream and returns an array of tokens.
    def tokenize
      @s.reset

      tokens = []

      while token = consume
        tokens << token
      end

      tokens
    end

    # Returns `true` if the given two-character _text_ is the beginning of a
    # valid escape sequence. If _text_ is `nil`, the current and next character
    # in the input stream will be checked, but will not be consumed.
    #
    # 4.3.9. http://dev.w3.org/csswg/css-syntax/#starts-with-a-valid-escape
    def valid_escape?(text = nil)
      text = @s.current + @s.peek if text.nil?
      !!(text[0] == '\\' && text[1] != "\n")
    end
  end

end
