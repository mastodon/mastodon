module JMESPath
  # @api private
  class TokenStream

    # @param [String<JMESPath>] expression
    # @param [Array<Token>] tokens
    def initialize(expression, tokens)
      @expression = expression
      @tokens = tokens
      @token = nil
      @position = -1
      self.next
    end

    # @return [String<JMESPath>]
    attr_reader :expression

    # @return [Token]
    attr_reader :token

    # @return [Integer]
    attr_reader :position

    # @option options [Array<Symbol>] :match Requires the next token to be
    #   one of the given symbols or an error is raised.
    def next(options = {})
      validate_match(_next, options[:match])
    end

    def lookahead(count)
      @tokens[@position + count] || Token::NULL_TOKEN
    end

    # @api private
    def inspect
      str = []
      @tokens.each do |token|
        str << "%3d  %-15s %s" %
         [token.position, token.type, token.value.inspect]
      end
      str.join("\n")
    end

    private

    def _next
      @position += 1
      @token = @tokens[@position] || Token::NULL_TOKEN
    end

    def validate_match(token, match)
      if match && !match.include?(token.type)
        raise Errors::SyntaxError, "type missmatch"
      else
        token
      end
    end

  end
end
