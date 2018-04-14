module JMESPath
  # @api private
  class Token < Struct.new(:type, :value, :position, :binding_power)

    NULL_TOKEN = Token.new(:eof, '', nil)

    BINDING_POWER = {
      Lexer::T_UNKNOWN           => 0,
      Lexer::T_EOF               => 0,
      Lexer::T_QUOTED_IDENTIFIER => 0,
      Lexer::T_IDENTIFIER        => 0,
      Lexer::T_RBRACKET          => 0,
      Lexer::T_RPAREN            => 0,
      Lexer::T_COMMA             => 0,
      Lexer::T_RBRACE            => 0,
      Lexer::T_NUMBER            => 0,
      Lexer::T_CURRENT           => 0,
      Lexer::T_EXPREF            => 0,
      Lexer::T_COLON             => 0,
      Lexer::T_PIPE              => 1,
      Lexer::T_OR                => 2,
      Lexer::T_AND               => 3,
      Lexer::T_COMPARATOR        => 5,
      Lexer::T_FLATTEN           => 9,
      Lexer::T_STAR              => 20,
      Lexer::T_FILTER            => 21,
      Lexer::T_DOT               => 40,
      Lexer::T_NOT               => 45,
      Lexer::T_LBRACE            => 50,
      Lexer::T_LBRACKET          => 55,
      Lexer::T_LPAREN            => 60,
    }

    # @param [Symbol] type
    # @param [Mixed] value
    # @param [Integer] position
    def initialize(type, value, position)
      super(type, value, position, BINDING_POWER[type])
    end

  end
end
