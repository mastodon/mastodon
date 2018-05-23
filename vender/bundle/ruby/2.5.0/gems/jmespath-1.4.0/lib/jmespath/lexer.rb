require 'json'
require 'set'

module JMESPath
  # @api private
  class Lexer

    T_DOT = :dot
    T_STAR = :star
    T_COMMA = :comma
    T_COLON = :colon
    T_CURRENT = :current
    T_EXPREF = :expref
    T_LPAREN = :lparen
    T_RPAREN = :rparen
    T_LBRACE = :lbrace
    T_RBRACE = :rbrace
    T_LBRACKET = :lbracket
    T_RBRACKET = :rbracket
    T_FLATTEN = :flatten
    T_IDENTIFIER = :identifier
    T_NUMBER = :number
    T_QUOTED_IDENTIFIER = :quoted_identifier
    T_UNKNOWN = :unknown
    T_PIPE = :pipe
    T_OR = :or
    T_AND = :and
    T_NOT = :not
    T_FILTER = :filter
    T_LITERAL = :literal
    T_EOF = :eof
    T_COMPARATOR = :comparator

    STATE_IDENTIFIER = 0
    STATE_NUMBER = 1
    STATE_SINGLE_CHAR = 2
    STATE_WHITESPACE = 3
    STATE_STRING_LITERAL = 4
    STATE_QUOTED_STRING = 5
    STATE_JSON_LITERAL = 6
    STATE_LBRACKET = 7
    STATE_PIPE = 8
    STATE_LT = 9
    STATE_GT = 10
    STATE_EQ = 11
    STATE_NOT = 12
    STATE_AND = 13

    TRANSLATION_TABLE = {
      '<'  => STATE_LT,
      '>'  => STATE_GT,
      '='  => STATE_EQ,
      '!'  => STATE_NOT,
      '['  => STATE_LBRACKET,
      '|'  => STATE_PIPE,
      '&'  => STATE_AND,
      '`'  => STATE_JSON_LITERAL,
      '"'  => STATE_QUOTED_STRING,
      "'"  => STATE_STRING_LITERAL,
      '-'  => STATE_NUMBER,
      '0'  => STATE_NUMBER,
      '1'  => STATE_NUMBER,
      '2'  => STATE_NUMBER,
      '3'  => STATE_NUMBER,
      '4'  => STATE_NUMBER,
      '5'  => STATE_NUMBER,
      '6'  => STATE_NUMBER,
      '7'  => STATE_NUMBER,
      '8'  => STATE_NUMBER,
      '9'  => STATE_NUMBER,
      ' '  => STATE_WHITESPACE,
      "\t" => STATE_WHITESPACE,
      "\n" => STATE_WHITESPACE,
      "\r" => STATE_WHITESPACE,
      '.'  => STATE_SINGLE_CHAR,
      '*'  => STATE_SINGLE_CHAR,
      ']'  => STATE_SINGLE_CHAR,
      ','  => STATE_SINGLE_CHAR,
      ':'  => STATE_SINGLE_CHAR,
      '@'  => STATE_SINGLE_CHAR,
      '('  => STATE_SINGLE_CHAR,
      ')'  => STATE_SINGLE_CHAR,
      '{'  => STATE_SINGLE_CHAR,
      '}'  => STATE_SINGLE_CHAR,
      '_'  => STATE_IDENTIFIER,
      'A'  => STATE_IDENTIFIER,
      'B'  => STATE_IDENTIFIER,
      'C'  => STATE_IDENTIFIER,
      'D'  => STATE_IDENTIFIER,
      'E'  => STATE_IDENTIFIER,
      'F'  => STATE_IDENTIFIER,
      'G'  => STATE_IDENTIFIER,
      'H'  => STATE_IDENTIFIER,
      'I'  => STATE_IDENTIFIER,
      'J'  => STATE_IDENTIFIER,
      'K'  => STATE_IDENTIFIER,
      'L'  => STATE_IDENTIFIER,
      'M'  => STATE_IDENTIFIER,
      'N'  => STATE_IDENTIFIER,
      'O'  => STATE_IDENTIFIER,
      'P'  => STATE_IDENTIFIER,
      'Q'  => STATE_IDENTIFIER,
      'R'  => STATE_IDENTIFIER,
      'S'  => STATE_IDENTIFIER,
      'T'  => STATE_IDENTIFIER,
      'U'  => STATE_IDENTIFIER,
      'V'  => STATE_IDENTIFIER,
      'W'  => STATE_IDENTIFIER,
      'X'  => STATE_IDENTIFIER,
      'Y'  => STATE_IDENTIFIER,
      'Z'  => STATE_IDENTIFIER,
      'a'  => STATE_IDENTIFIER,
      'b'  => STATE_IDENTIFIER,
      'c'  => STATE_IDENTIFIER,
      'd'  => STATE_IDENTIFIER,
      'e'  => STATE_IDENTIFIER,
      'f'  => STATE_IDENTIFIER,
      'g'  => STATE_IDENTIFIER,
      'h'  => STATE_IDENTIFIER,
      'i'  => STATE_IDENTIFIER,
      'j'  => STATE_IDENTIFIER,
      'k'  => STATE_IDENTIFIER,
      'l'  => STATE_IDENTIFIER,
      'm'  => STATE_IDENTIFIER,
      'n'  => STATE_IDENTIFIER,
      'o'  => STATE_IDENTIFIER,
      'p'  => STATE_IDENTIFIER,
      'q'  => STATE_IDENTIFIER,
      'r'  => STATE_IDENTIFIER,
      's'  => STATE_IDENTIFIER,
      't'  => STATE_IDENTIFIER,
      'u'  => STATE_IDENTIFIER,
      'v'  => STATE_IDENTIFIER,
      'w'  => STATE_IDENTIFIER,
      'x'  => STATE_IDENTIFIER,
      'y'  => STATE_IDENTIFIER,
      'z'  => STATE_IDENTIFIER,
    }

    VALID_IDENTIFIERS = Set.new(%w(
      A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
      a b c d e f g h i j k l m n o p q r s t u v w x y z
      _ 0 1 2 3 4 5 6 7 8 9
    ))

    NUMBERS = Set.new(%w(0 1 2 3 4 5 6 7 8 9))

    SIMPLE_TOKENS = {
      '.' => T_DOT,
      '*' => T_STAR,
      ']' => T_RBRACKET,
      ',' => T_COMMA,
      ':' => T_COLON,
      '@' => T_CURRENT,
      '(' => T_LPAREN,
      ')' => T_RPAREN,
      '{' => T_LBRACE,
      '}' => T_RBRACE,
    }

    # @param [String<JMESPath>] expression
    # @return [Array<Hash>]
    def tokenize(expression)

      tokens = []
      chars = CharacterStream.new(expression.chars.to_a)

      while chars.current
        case TRANSLATION_TABLE[chars.current]
        when nil
          tokens << Token.new(
            T_UNKNOWN,
            chars.current,
            chars.position
          )
          chars.next
        when STATE_SINGLE_CHAR
          # consume simple tokens like ".", ",", "@", etc.
          tokens << Token.new(
            SIMPLE_TOKENS[chars.current],
            chars.current,
            chars.position
          )
          chars.next
        when STATE_IDENTIFIER
          start = chars.position
          buffer = []
          begin
            buffer << chars.current
            chars.next
          end while VALID_IDENTIFIERS.include?(chars.current)
          tokens << Token.new(
            T_IDENTIFIER,
            buffer.join,
            start
          )
        when STATE_WHITESPACE
          # skip whitespace
          chars.next
        when STATE_LBRACKET
          # consume "[", "[?" and "[]"
          position = chars.position
          actual = chars.next
          if actual == ']'
            chars.next
            tokens << Token.new(T_FLATTEN, '[]', position)
          elsif actual == '?'
            chars.next
            tokens << Token.new(T_FILTER, '[?', position)
          else
            tokens << Token.new(T_LBRACKET, '[',  position)
          end
        when STATE_STRING_LITERAL
          # consume raw string literals
          t = inside(chars, "'", T_LITERAL)
          t.value = t.value.gsub("\\'", "'")
          tokens << t
        when STATE_PIPE
          # consume pipe and OR
          tokens << match_or(chars, '|', '|', T_OR, T_PIPE)
        when STATE_JSON_LITERAL
          # consume JSON literals
          token = inside(chars, '`', T_LITERAL)
          if token.type == T_LITERAL
            token.value = token.value.gsub('\\`', '`')
            token = parse_json(token)
          end
          tokens << token
        when STATE_NUMBER
          start = chars.position
          buffer = []
          begin
            buffer << chars.current
            chars.next
          end while NUMBERS.include?(chars.current)
          tokens << Token.new(
            T_NUMBER,
            buffer.join.to_i,
            start
          )
        when STATE_QUOTED_STRING
          # consume quoted identifiers
          token = inside(chars, '"', T_QUOTED_IDENTIFIER)
          if token.type == T_QUOTED_IDENTIFIER
            token.value = "\"#{token.value}\""
            token = parse_json(token, true)
          end
          tokens << token
        when STATE_EQ
          # consume equals
          tokens << match_or(chars, '=', '=', T_COMPARATOR, T_UNKNOWN)
        when STATE_AND
          tokens << match_or(chars, '&', '&', T_AND, T_EXPREF)
        when STATE_NOT
          # consume not equals
          tokens << match_or(chars, '!', '=', T_COMPARATOR, T_NOT);
        else
          # either '<' or '>'
          # consume less than and greater than
          tokens << match_or(chars, chars.current, '=', T_COMPARATOR, T_COMPARATOR)
        end
      end
      tokens << Token.new(T_EOF, nil, chars.position)
      tokens
    end

    private

    def match_or(chars, current, expected, type, or_type)
      if chars.next == expected
        chars.next
        Token.new(type, current + expected, chars.position - 1)
      else
        Token.new(or_type, current, chars.position - 1)
      end
    end

    def inside(chars, delim, type)
      position = chars.position
      current = chars.next
      buffer = []
      while current != delim
        if current == '\\'
          buffer << current
          current = chars.next
        end
        if current.nil?
          # unclosed delimiter
          return Token.new(T_UNKNOWN, buffer.join, position)
        end
        buffer << current
        current = chars.next
      end
      chars.next
      Token.new(type, buffer.join, position)
    end

    # Certain versions of Ruby and of the pure_json gem not support loading
    # scalar JSON values, such a numbers, booleans, strings, etc. These
    # simple values must be first wrapped inside a JSON object before calling
    # `JSON.load`.
    #
    #    # works in most JSON versions, raises in some versions
    #    JSON.load("true")
    #    JSON.load("123")
    #    JSON.load("\"abc\"")
    #
    # This is an known issue for:
    #
    # * Ruby 1.9.3 bundled v1.5.5 of json; Ruby 1.9.3 defaults to bundled
    #   version despite newer versions being available.
    #
    # * json_pure v2.0.0+
    #
    # It is not possible to change the version of JSON loaded in the
    # user's application. Adding an explicit dependency on json gem
    # causes issues in environments that cannot compile the gem. We previously
    # had a direct dependency on `json_pure`, but this broke with the v2 update.
    #
    # This method allows us to detect how the `JSON.load` behaves so we know
    # if we have to wrap scalar JSON values to parse them or not.
    # @api private
    def self.requires_wrapping?
      begin
        JSON.load('false')
      rescue JSON::ParserError
        true
      end
    end

    if requires_wrapping?
      def parse_json(token, quoted = false)
        begin
          if quoted
            token.value = JSON.load("{\"value\":#{token.value}}")['value']
          else
            begin
              token.value = JSON.load("{\"value\":#{token.value}}")['value']
            rescue
              token.value = JSON.load(sprintf('{"value":"%s"}', token.value.lstrip))['value']
            end
          end
        rescue JSON::ParserError
          token.type = T_UNKNOWN
        end
        token
      end
    else
      def parse_json(token, quoted = false)
        begin
          if quoted
            token.value = JSON.load(token.value)
          else
            token.value = JSON.load(token.value) rescue JSON.load(sprintf('"%s"', token.value.lstrip))
          end
        rescue JSON::ParserError
          token.type = T_UNKNOWN
        end
        token
      end
    end

    class CharacterStream

      def initialize(chars)
        @chars = chars
        @position = 0
      end

      def current
        @chars[@position]
      end

      def next
        @position += 1
        @chars[@position]
      end

      def position
        @position
      end

    end
  end
end
