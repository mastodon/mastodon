require 'set'

module JMESPath
  # @api private
  class Parser

    AFTER_DOT = Set.new([
      Lexer::T_IDENTIFIER,        # foo.bar
      Lexer::T_QUOTED_IDENTIFIER, # foo."bar"
      Lexer::T_STAR,              # foo.*
      Lexer::T_LBRACE,            # foo{a: 0}
      Lexer::T_LBRACKET,          # foo[1]
      Lexer::T_FILTER,            # foo.[?bar==10]
    ])

    NUM_COLON_RBRACKET = Set.new([
      Lexer::T_NUMBER,
      Lexer::T_COLON,
      Lexer::T_RBRACKET,
    ])

    COLON_RBRACKET = Set.new([
      Lexer::T_COLON,
      Lexer::T_RBRACKET,
    ])

    CURRENT_NODE = Nodes::Current.new

    # @option options [Lexer] :lexer
    def initialize(options = {})
      @lexer = options[:lexer] || Lexer.new
      @disable_visit_errors = options[:disable_visit_errors]
    end

    # @param [String<JMESPath>] expression
    def parse(expression)
      tokens =  @lexer.tokenize(expression)
      stream = TokenStream.new(expression, tokens)
      result = expr(stream)
      if stream.token.type != Lexer::T_EOF
        raise Errors::SyntaxError, "expected :eof got #{stream.token.type}"
      else
        result
      end
    end

    # @api private
    def method_missing(method_name, *args)
      if matches = method_name.to_s.match(/^(nud_|led_)(.*)/)
        raise Errors::SyntaxError, "unexpected token #{matches[2]}"
      else
        super
      end
    end

    private

    # @param [TokenStream] stream
    # @param [Integer] rbp Right binding power
    def expr(stream, rbp = 0)
      left = send("nud_#{stream.token.type}", stream)
      while rbp < (stream.token.binding_power || 0)
        left = send("led_#{stream.token.type}", stream, left)
      end
      left
    end

    def nud_current(stream)
      stream.next
      CURRENT_NODE
    end

    def nud_expref(stream)
      stream.next
      Nodes::Expression.new(expr(stream, Token::BINDING_POWER[:expref]))
    end

    def nud_not(stream)
      stream.next
      Nodes::Not.new(expr(stream, Token::BINDING_POWER[:not]))
    end

    def nud_lparen(stream)
      stream.next
      result = expr(stream, 0)
      if stream.token.type != Lexer::T_RPAREN
        raise Errors::SyntaxError, 'Unclosed `(`'
      end
      stream.next
      result
    end

    def nud_filter(stream)
      led_filter(stream, CURRENT_NODE)
    end

    def nud_flatten(stream)
      led_flatten(stream, CURRENT_NODE)
    end

    def nud_identifier(stream)
      token = stream.token
      n = stream.next
      if n.type == :lparen
        Nodes::Function::FunctionName.new(token.value)
      else
        Nodes::Field.new(token.value)
      end
    end

    def nud_lbrace(stream)
      valid_keys = Set.new([:quoted_identifier, :identifier])
      stream.next(match:valid_keys)
      pairs = []
      begin
        pairs << parse_key_value_pair(stream)
        if stream.token.type == :comma
          stream.next(match:valid_keys)
        end
      end while stream.token.type != :rbrace
      stream.next
      Nodes::MultiSelectHash.new(pairs)
    end

    def nud_lbracket(stream)
      stream.next
      type = stream.token.type
      if type == :number || type == :colon
        parse_array_index_expression(stream)
      elsif type == :star && stream.lookahead(1).type == :rbracket
        parse_wildcard_array(stream)
      else
        parse_multi_select_list(stream)
      end
    end

    def nud_literal(stream)
      value = stream.token.value
      stream.next
      Nodes::Literal.new(value)
    end

    def nud_quoted_identifier(stream)
      token = stream.token
      next_token = stream.next
      if next_token.type == :lparen
        msg = 'quoted identifiers are not allowed for function names'
        raise Errors::SyntaxError, msg
      else
        Nodes::Field.new(token[:value])
      end
    end

    def nud_star(stream)
      parse_wildcard_object(stream, CURRENT_NODE)
    end

    def nud_unknown(stream)
      raise Errors::SyntaxError, "unknown token #{stream.token.value.inspect}"
    end

    def led_comparator(stream, left)
      token = stream.token
      stream.next
      right = expr(stream, Token::BINDING_POWER[:comparator])
      Nodes::Comparator.create(token.value, left, right)
    end

    def led_dot(stream, left)
      stream.next(match:AFTER_DOT)
      if stream.token.type == :star
        parse_wildcard_object(stream, left)
      else
        right = parse_dot(stream, Token::BINDING_POWER[:dot])
        Nodes::Subexpression.new(left, right)
      end
    end

    def led_filter(stream, left)
      stream.next
      expression = expr(stream)
      if stream.token.type != Lexer::T_RBRACKET
        raise Errors::SyntaxError, 'expected a closing rbracket for the filter'
      end
      stream.next
      rhs = parse_projection(stream, Token::BINDING_POWER[Lexer::T_FILTER])
      left ||= CURRENT_NODE
      right = Nodes::Condition.new(expression, rhs)
      Nodes::ArrayProjection.new(left, right)
    end

    def led_flatten(stream, left)
      stream.next
      left = Nodes::Flatten.new(left)
      right = parse_projection(stream, Token::BINDING_POWER[:flatten])
      Nodes::ArrayProjection.new(left, right)
    end

    def led_lbracket(stream, left)
      stream.next(match: Set.new([:number, :colon, :star]))
      type = stream.token.type
      if type == :number || type == :colon
        right = parse_array_index_expression(stream)
        Nodes::Subexpression.new(left, right)
      else
        parse_wildcard_array(stream, left)
      end
    end

    def led_lparen(stream, left)
      args = []
      if Nodes::Function::FunctionName === left
        name = left.name
      else
        raise Errors::SyntaxError, 'invalid function invocation'
      end
      stream.next
      while stream.token.type != :rparen
        args << expr(stream, 0)
        if stream.token.type == :comma
          stream.next
        end
      end
      stream.next
      Nodes::Function.create(name, args, :disable_visit_errors => @disable_visit_errors)
    end

    def led_or(stream, left)
      stream.next
      right = expr(stream, Token::BINDING_POWER[:or])
      Nodes::Or.new(left, right)
    end

    def led_and(stream, left)
      stream.next
      right = expr(stream, Token::BINDING_POWER[:or])
      Nodes::And.new(left, right)
    end

    def led_pipe(stream, left)
      stream.next
      right = expr(stream, Token::BINDING_POWER[:pipe])
      Nodes::Pipe.new(left, right)
    end

    # parse array index expressions, for example [0], [1:2:3], etc.
    def parse_array_index_expression(stream)
      pos = 0
      parts = [nil, nil, nil]
      expected = NUM_COLON_RBRACKET

      begin
        if stream.token.type == Lexer::T_COLON
          pos += 1
          expected = NUM_COLON_RBRACKET
        elsif stream.token.type == Lexer::T_NUMBER
          parts[pos] = stream.token.value
          expected = COLON_RBRACKET
        end
        stream.next(match: expected)
      end while stream.token.type != Lexer::T_RBRACKET

      stream.next # consume the closing bracket

      if pos == 0
        # no colons found, this is a single index extraction
        Nodes::Index.new(parts[0])
      elsif pos > 2
        raise Errors::SyntaxError, 'invalid array slice syntax: too many colons'
      else
        Nodes::ArrayProjection.new(
          Nodes::Slice.new(*parts),
          parse_projection(stream, Token::BINDING_POWER[Lexer::T_STAR])
        )
      end
    end

    def parse_dot(stream, binding_power)
      if stream.token.type == :lbracket
        stream.next
        parse_multi_select_list(stream)
      else
        expr(stream, binding_power)
      end
    end

    def parse_key_value_pair(stream)
      key = stream.token.value
      stream.next(match:Set.new([:colon]))
      stream.next
      Nodes::MultiSelectHash::KeyValuePair.new(key, expr(stream))
    end

    def parse_multi_select_list(stream)
      nodes = []
      begin
        nodes << expr(stream)
        if stream.token.type == :comma
          stream.next
          if stream.token.type == :rbracket
            raise Errors::SyntaxError, 'expression epxected, found rbracket'
          end
        end
      end while stream.token.type != :rbracket
      stream.next
      Nodes::MultiSelectList.new(nodes)
    end

    def parse_projection(stream, binding_power)
      type = stream.token.type
      if stream.token.binding_power < 10
        CURRENT_NODE
      elsif type == :dot
        stream.next(match:AFTER_DOT)
        parse_dot(stream, binding_power)
      elsif type == :lbracket || type == :filter
        expr(stream, binding_power)
      else
        raise Errors::SyntaxError, 'syntax error after projection'
      end
    end

    def parse_wildcard_array(stream, left = nil)
      stream.next(match:Set.new([:rbracket]))
      stream.next
      left ||= CURRENT_NODE
      right = parse_projection(stream, Token::BINDING_POWER[:star])
      Nodes::ArrayProjection.new(left, right)
    end

    def parse_wildcard_object(stream, left = nil)
      stream.next
      left ||= CURRENT_NODE
      right = parse_projection(stream, Token::BINDING_POWER[:star])
      Nodes::ObjectProjection.new(left, right)
    end

  end
end
