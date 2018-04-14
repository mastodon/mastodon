# encoding: utf-8

module Crass

  # Like {Scanner}, but for tokens!
  class TokenScanner
    attr_reader :current, :pos, :tokens

    def initialize(tokens)
      @tokens = tokens.to_a
      reset
    end

    # Executes the given block, collects all tokens that are consumed during its
    # execution, and returns them.
    def collect
      start = @pos
      yield
      @tokens[start...@pos] || []
    end

    # Consumes the next token and returns it, advancing the pointer. Returns
    # `nil` if there is no next token.
    def consume
      @current = @tokens[@pos]
      @pos += 1 if @current
      @current
    end

    # Returns the next token without consuming it, or `nil` if there is no next
    # token.
    def peek
      @tokens[@pos]
    end

    # Reconsumes the current token, moving the pointer back one position.
    #
    # http://www.w3.org/TR/2013/WD-css-syntax-3-20130919/#reconsume-the-current-input-token
    def reconsume
      @pos -= 1 if @pos > 0
    end

    # Resets the pointer to the first token in the list.
    def reset
      @current = nil
      @pos     = 0
    end
  end

end
