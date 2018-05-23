# encoding: utf-8
require_relative 'token-scanner'
require_relative 'tokenizer'

module Crass

  # Parses a CSS string or list of tokens.
  #
  # 5. http://dev.w3.org/csswg/css-syntax/#parsing
  class Parser
    BLOCK_END_TOKENS = {
      :'{' => :'}',
      :'[' => :']',
      :'(' => :')'
    }

    # -- Class Methods ---------------------------------------------------------

    # Parses CSS properties (such as the contents of an HTML element's `style`
    # attribute) and returns a parse tree.
    #
    # See {Tokenizer#initialize} for _options_.
    #
    # 5.3.6. http://dev.w3.org/csswg/css-syntax/#parse-a-list-of-declarations
    def self.parse_properties(input, options = {})
      Parser.new(input, options).parse_properties
    end

    # Parses CSS rules (such as the content of a `@media` block) and returns a
    # parse tree. The only difference from {parse_stylesheet} is that CDO/CDC
    # nodes (`<!--` and `-->`) aren't ignored.
    #
    # See {Tokenizer#initialize} for _options_.
    #
    # 5.3.3. http://dev.w3.org/csswg/css-syntax/#parse-a-list-of-rules
    def self.parse_rules(input, options = {})
      parser = Parser.new(input, options)
      rules  = parser.consume_rules

      rules.map do |rule|
        if rule[:node] == :qualified_rule
          parser.create_style_rule(rule)
        else
          rule
        end
      end
    end

    # Parses a CSS stylesheet and returns a parse tree.
    #
    # See {Tokenizer#initialize} for _options_.
    #
    # 5.3.2. http://dev.w3.org/csswg/css-syntax/#parse-a-stylesheet
    def self.parse_stylesheet(input, options = {})
      parser = Parser.new(input, options)
      rules  = parser.consume_rules(:top_level => true)

      rules.map do |rule|
        if rule[:node] == :qualified_rule
          parser.create_style_rule(rule)
        else
          rule
        end
      end
    end

    # Converts a node or array of nodes into a CSS string based on their
    # original tokenized input.
    #
    # Options:
    #
    #   * **:exclude_comments** - When `true`, comments will be excluded.
    #
    def self.stringify(nodes, options = {})
      nodes  = [nodes] unless nodes.is_a?(Array)
      string = String.new

      nodes.each do |node|
        next if node.nil?

        case node[:node]
        when :at_rule
          string << '@'
          string << node[:name]
          string << self.stringify(node[:prelude], options)

          if node[:block]
            string << '{' << self.stringify(node[:block], options) << '}'
          else
            string << ';'
          end

        when :comment
          string << node[:raw] unless options[:exclude_comments]

        when :simple_block
          string << node[:start]
          string << self.stringify(node[:value], options)
          string << node[:end]

        when :style_rule
          string << self.stringify(node[:selector][:tokens], options)
          string << '{' << self.stringify(node[:children], options) << '}'

        else
          if node.key?(:raw)
            string << node[:raw]
          elsif node.key?(:tokens)
            string << self.stringify(node[:tokens], options)
          end
        end
      end

      string
    end

    # -- Instance Methods ------------------------------------------------------

    # {TokenScanner} wrapping the tokens generated from this parser's input.
    attr_reader :tokens

    # Initializes a parser based on the given _input_, which may be a CSS string
    # or an array of tokens.
    #
    # See {Tokenizer#initialize} for _options_.
    def initialize(input, options = {})
      unless input.kind_of?(Enumerable)
        input = Tokenizer.tokenize(input, options)
      end

      @tokens = TokenScanner.new(input)
    end

    # Consumes an at-rule and returns it.
    #
    # 5.4.2. http://dev.w3.org/csswg/css-syntax-3/#consume-at-rule
    def consume_at_rule(input = @tokens)
      rule = {}

      rule[:tokens] = input.collect do
        rule[:name]    = input.consume[:value]
        rule[:prelude] = []

        while token = input.consume
          node = token[:node]

          if node == :comment # Non-standard.
            next

          elsif node == :semicolon
            break

          elsif node === :'{'
            # Note: The spec says the block should _be_ the consumed simple
            # block, but Simon Sapin's CSS parsing tests and tinycss2 expect
            # only the _value_ of the consumed simple block here. I assume I'm
            # interpreting the spec too literally, so I'm going with the
            # tinycss2 behavior.
            rule[:block] = consume_simple_block(input)[:value]
            break

          elsif node == :simple_block && token[:start] == '{'
            # Note: The spec says the block should _be_ the simple block, but
            # Simon Sapin's CSS parsing tests and tinycss2 expect only the
            # _value_ of the simple block here. I assume I'm interpreting the
            # spec too literally, so I'm going with the tinycss2 behavior.
            rule[:block] = token[:value]
            break

          else
            input.reconsume
            rule[:prelude] << consume_component_value(input)
          end
        end
      end

      create_node(:at_rule, rule)
    end

    # Consumes a component value and returns it, or `nil` if there are no more
    # tokens.
    #
    # 5.4.6. http://dev.w3.org/csswg/css-syntax-3/#consume-a-component-value
    def consume_component_value(input = @tokens)
      return nil unless token = input.consume

      case token[:node]
      when :'{', :'[', :'('
        consume_simple_block(input)

      when :function
        if token.key?(:name)
          # This is a parsed function, not a function token. This step isn't
          # mentioned in the spec, but it's necessary to avoid re-parsing
          # functions that have already been parsed.
          token
        else
          consume_function(input)
        end

      else
        token
      end
    end

    # Consumes a declaration and returns it, or `nil` on parse error.
    #
    # 5.4.5. http://dev.w3.org/csswg/css-syntax-3/#consume-a-declaration
    def consume_declaration(input = @tokens)
      declaration = {}
      value       = []

      declaration[:tokens] = input.collect do
        declaration[:name] = input.consume[:value]

        next_token = input.peek

        while next_token && next_token[:node] == :whitespace
          input.consume
          next_token = input.peek
        end

        unless next_token && next_token[:node] == :colon
          # Parse error.
          #
          # Note: The spec explicitly says to return nothing here, but Simon
          # Sapin's CSS parsing tests expect an error node.
          return create_node(:error, :value => 'invalid')
        end

        input.consume

        until input.peek.nil?
          value << consume_component_value(input)
        end
      end

      # Look for !important.
      important_tokens = value.reject {|token|
        node = token[:node]
        node == :whitespace || node == :comment || node == :semicolon
      }.last(2)

      if important_tokens.size == 2 &&
          important_tokens[0][:node] == :delim &&
          important_tokens[0][:value] == '!' &&
          important_tokens[1][:node] == :ident &&
          important_tokens[1][:value].downcase == 'important'

        declaration[:important] = true
        excl_index = value.index(important_tokens[0])

        # Technically the spec doesn't require us to trim trailing tokens after
        # the !important, but Simon Sapin's CSS parsing tests expect it and
        # tinycss2 does it, so we'll go along with the cool kids.
        value.slice!(excl_index, value.size - excl_index)
      else
        declaration[:important] = false
      end

      declaration[:value] = value
      create_node(:declaration, declaration)
    end

    # Consumes a list of declarations and returns them.
    #
    # By default, the returned list may include `:comment`, `:semicolon`, and
    # `:whitespace` nodes, which is non-standard.
    #
    # Options:
    #
    #   * **:strict** - Set to `true` to exclude non-standard `:comment`,
    #     `:semicolon`, and `:whitespace` nodes.
    #
    # 5.4.4. http://dev.w3.org/csswg/css-syntax/#consume-a-list-of-declarations
    def consume_declarations(input = @tokens, options = {})
      declarations = []

      while token = input.consume
        case token[:node]

        # Non-standard: Preserve comments, semicolons, and whitespace.
        when :comment, :semicolon, :whitespace
          declarations << token unless options[:strict]

        when :at_keyword
          # When parsing a style rule, this is a parse error. Otherwise it's
          # not.
          input.reconsume
          declarations << consume_at_rule(input)

        when :ident
          decl_tokens = [token]

          while next_token = input.peek
            break if next_token[:node] == :semicolon
            decl_tokens << consume_component_value(input)
          end

          if decl = consume_declaration(TokenScanner.new(decl_tokens))
            declarations << decl
          end

        else
          # Parse error (invalid property name, etc.).
          #
          # Note: The spec doesn't say we should append anything to the list of
          # declarations here, but Simon Sapin's CSS parsing tests expect an
          # error node.
          declarations << create_node(:error, :value => 'invalid')
          input.reconsume

          while next_token = input.peek
            break if next_token[:node] == :semicolon
            consume_component_value(input)
          end
        end
      end

      declarations
    end

    # Consumes a function and returns it.
    #
    # 5.4.8. http://dev.w3.org/csswg/css-syntax-3/#consume-a-function
    def consume_function(input = @tokens)
      function = {
        :name   => input.current[:value],
        :value  => [],
        :tokens => [input.current] # Non-standard, used for serialization.
      }

      function[:tokens].concat(input.collect {
        while token = input.consume
          case token[:node]
          when :')'
            break

          # Non-standard.
          when :comment
            next

          else
            input.reconsume
            function[:value] << consume_component_value(input)
          end
        end
      })

      create_node(:function, function)
    end

    # Consumes a qualified rule and returns it, or `nil` if a parse error
    # occurs.
    #
    # 5.4.3. http://dev.w3.org/csswg/css-syntax-3/#consume-a-qualified-rule
    def consume_qualified_rule(input = @tokens)
      rule = {:prelude => []}

      rule[:tokens] = input.collect do
        while true
          unless token = input.consume
            # Parse error.
            #
            # Note: The spec explicitly says to return nothing here, but Simon
            # Sapin's CSS parsing tests expect an error node.
            return create_node(:error, :value => 'invalid')
          end

          if token[:node] == :'{'
            # Note: The spec says the block should _be_ the consumed simple
            # block, but Simon Sapin's CSS parsing tests and tinycss2 expect
            # only the _value_ of the consumed simple block here. I assume I'm
            # interpreting the spec too literally, so I'm going with the
            # tinycss2 behavior.
            rule[:block] = consume_simple_block(input)[:value]
            break
          elsif token[:node] == :simple_block && token[:start] == '{'
            # Note: The spec says the block should _be_ the simple block, but
            # Simon Sapin's CSS parsing tests and tinycss2 expect only the
            # _value_ of the simple block here. I assume I'm interpreting the
            # spec too literally, so I'm going with the tinycss2 behavior.
            rule[:block] = token[:value]
            break
          else
            input.reconsume
            rule[:prelude] << consume_component_value(input)
          end
        end
      end

      create_node(:qualified_rule, rule)
    end

    # Consumes a list of rules and returns them.
    #
    # 5.4.1. http://dev.w3.org/csswg/css-syntax/#consume-a-list-of-rules
    def consume_rules(flags = {})
      rules = []

      while token = @tokens.consume
        case token[:node]
          # Non-standard. Spec says to discard comments and whitespace, but we
          # keep them so we can serialize faithfully.
          when :comment, :whitespace
            rules << token

          when :cdc, :cdo
            unless flags[:top_level]
              @tokens.reconsume
              rule = consume_qualified_rule
              rules << rule if rule
            end

          when :at_keyword
            @tokens.reconsume
            rule = consume_at_rule
            rules << rule if rule

          else
            @tokens.reconsume
            rule = consume_qualified_rule
            rules << rule if rule
        end
      end

      rules
    end

    # Consumes and returns a simple block associated with the current input
    # token.
    #
    # 5.4.7. http://dev.w3.org/csswg/css-syntax/#consume-a-simple-block
    def consume_simple_block(input = @tokens)
      start_token = input.current[:node]
      end_token   = BLOCK_END_TOKENS[start_token]

      block = {
        :start  => start_token.to_s,
        :end    => end_token.to_s,
        :value  => [],
        :tokens => [input.current] # Non-standard. Used for serialization.
      }

      block[:tokens].concat(input.collect do
        while token = input.consume
          break if token[:node] == end_token

          input.reconsume
          block[:value] << consume_component_value(input)
        end
      end)

      create_node(:simple_block, block)
    end

    # Creates and returns a new parse node with the given _properties_.
    def create_node(type, properties = {})
      {:node => type}.merge!(properties)
    end

    # Parses the given _input_ tokens into a selector node and returns it.
    #
    # Doesn't bother splitting the selector list into individual selectors or
    # validating them. Feel free to do that yourself! It'll be fun!
    def create_selector(input)
      create_node(:selector,
        :value  => parse_value(input),
        :tokens => input)
    end

    # Creates a `:style_rule` node from the given qualified _rule_, and returns
    # it.
    def create_style_rule(rule)
      create_node(:style_rule,
        :selector => create_selector(rule[:prelude]),
        :children => parse_properties(rule[:block]))
    end

    # Parses a single component value and returns it.
    #
    # 5.3.7. http://dev.w3.org/csswg/css-syntax-3/#parse-a-component-value
    def parse_component_value(input = @tokens)
      input = TokenScanner.new(input) unless input.is_a?(TokenScanner)

      while input.peek && input.peek[:node] == :whitespace
        input.consume
      end

      if input.peek.nil?
        return create_node(:error, :value => 'empty')
      end

      value = consume_component_value(input)

      while input.peek && input.peek[:node] == :whitespace
        input.consume
      end

      if input.peek.nil?
        value
      else
        create_node(:error, :value => 'extra-input')
      end
    end

    # Parses a list of component values and returns an array of parsed tokens.
    #
    # 5.3.8. http://dev.w3.org/csswg/css-syntax/#parse-a-list-of-component-values
    def parse_component_values(input = @tokens)
      input  = TokenScanner.new(input) unless input.is_a?(TokenScanner)
      tokens = []

      while token = consume_component_value(input)
        tokens << token
      end

      tokens
    end

    # Parses a single declaration and returns it.
    #
    # 5.3.5. http://dev.w3.org/csswg/css-syntax/#parse-a-declaration
    def parse_declaration(input = @tokens)
      input = TokenScanner.new(input) unless input.is_a?(TokenScanner)

      while input.peek && input.peek[:node] == :whitespace
        input.consume
      end

      if input.peek.nil?
        # Syntax error.
        return create_node(:error, :value => 'empty')
      elsif input.peek[:node] != :ident
        # Syntax error.
        return create_node(:error, :value => 'invalid')
      end

      if decl = consume_declaration(input)
        return decl
      end

      # Syntax error.
      create_node(:error, :value => 'invalid')
    end

    # Parses a list of declarations and returns them.
    #
    # See {#consume_declarations} for _options_.
    #
    # 5.3.6. http://dev.w3.org/csswg/css-syntax/#parse-a-list-of-declarations
    def parse_declarations(input = @tokens, options = {})
      input = TokenScanner.new(input) unless input.is_a?(TokenScanner)
      consume_declarations(input, options)
    end

    # Parses a list of declarations and returns an array of `:property` nodes
    # (and any non-declaration nodes that were in the input). This is useful for
    # parsing the contents of an HTML element's `style` attribute.
    def parse_properties(input = @tokens)
      properties = []

      parse_declarations(input).each do |decl|
        unless decl[:node] == :declaration
          properties << decl
          next
        end

        children = decl[:value].dup
        children.pop if children.last && children.last[:node] == :semicolon

        properties << create_node(:property,
          :name      => decl[:name],
          :value     => parse_value(decl[:value]),
          :children  => children,
          :important => decl[:important],
          :tokens    => decl[:tokens])
      end

      properties
    end

    # Parses a single rule and returns it.
    #
    # 5.3.4. http://dev.w3.org/csswg/css-syntax-3/#parse-a-rule
    def parse_rule(input = @tokens)
      input = TokenScanner.new(input) unless input.is_a?(TokenScanner)

      while input.peek && input.peek[:node] == :whitespace
        input.consume
      end

      if input.peek.nil?
        # Syntax error.
        return create_node(:error, :value => 'empty')
      elsif input.peek[:node] == :at_keyword
        rule = consume_at_rule(input)
      else
        rule = consume_qualified_rule(input)
      end

      while input.peek && input.peek[:node] == :whitespace
        input.consume
      end

      if input.peek.nil?
        rule
      else
        # Syntax error.
        create_node(:error, :value => 'extra-input')
      end
    end

    # Returns the unescaped value of a selector name or property declaration.
    def parse_value(nodes)
      nodes  = [nodes] unless nodes.is_a?(Array)
      string = String.new

      nodes.each do |node|
        case node[:node]
        when :comment, :semicolon
          next

        when :at_keyword, :ident
          string << node[:value]

        when :function
          if node[:value].is_a?(String)
            string << node[:value]
            string << '('
          else
            string << parse_value(node[:tokens])
          end

        else
          if node.key?(:raw)
            string << node[:raw]
          elsif node.key?(:tokens)
            string << parse_value(node[:tokens])
          end
        end
      end

      string.strip
    end
  end

end
