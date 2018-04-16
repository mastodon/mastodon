module Temple
  module Mixins
    # @api private
    module GrammarDSL
      class Rule
        def initialize(grammar)
          @grammar = grammar
        end

        def match?(exp)
          match(exp, [])
        end
        alias === match?
        alias =~ match?

        def |(rule)
          Or.new(@grammar, self, rule)
        end

        def copy_to(grammar)
          copy = dup.instance_eval { @grammar = grammar; self }
          copy.after_copy(self) if copy.respond_to?(:after_copy)
          copy
        end
      end

      class Or < Rule
        def initialize(grammar, *children)
          super(grammar)
          @children = children.map {|rule| @grammar.Rule(rule) }
        end

        def <<(rule)
          @children << @grammar.Rule(rule)
          self
        end

        alias | <<

        def match(exp, unmatched)
          tmp = []
          @children.any? {|rule| rule.match(exp, tmp) } || (unmatched.concat(tmp) && false)
        end

        def after_copy(source)
          @children = @children.map {|child| child.copy_to(@grammar) }
        end
      end

      class Root < Or
        def initialize(grammar, name)
          super(grammar)
          @name = name.to_sym
        end

        def match(exp, unmatched)
          success = super
          unmatched << [@name, exp] unless success
          success
        end

        def validate!(exp)
          unmatched = []
          unless match(exp, unmatched)
            require 'pp'
            entry = unmatched.first
            unmatched.reverse_each do |u|
              entry = u if u.flatten.size < entry.flatten.size
            end
            raise(InvalidExpression, PP.pp(entry.last, "#{@grammar}::#{entry.first} did not match\n"))
          end
        end

        def copy_to(grammar)
          grammar.const_defined?(@name) ? grammar.const_get(@name) : super
        end

        def after_copy(source)
          @grammar.const_set(@name, self)
          super
        end
      end

      class Element < Or
        def initialize(grammar, rule)
          super(grammar)
          @rule = grammar.Rule(rule)
        end

        def match(exp, unmatched)
          return false unless Array === exp && !exp.empty?
          head, *tail = exp
          @rule.match(head, unmatched) && super(tail, unmatched)
        end

        def after_copy(source)
          @children = @children.map do |child|
            child == source ? self : child.copy_to(@grammar)
          end
          @rule = @rule.copy_to(@grammar)
        end
      end

      class Value < Rule
        def initialize(grammar, value)
          super(grammar)
          @value = value
        end

        def match(exp, unmatched)
          @value === exp
        end
      end

      def extended(mod)
        mod.extend GrammarDSL
        constants.each do |name|
          const_get(name).copy_to(mod) if Rule === const_get(name)
        end
      end

      def match?(exp)
        const_get(:Expression).match?(exp)
      end
      alias === match?
      alias =~ match?

      def validate!(exp)
        const_get(:Expression).validate!(exp)
      end

      def Value(value)
        Value.new(self, value)
      end

      def Rule(rule)
        case rule
        when Rule
          rule
        when Symbol, Class, true, false, nil
          Value(rule)
        when Array
          start = Or.new(self)
          curr = [start]
          rule.each do |elem|
            if elem =~ /^(.*)(\*|\?|\+)$/
              elem = Element.new(self, const_get($1))
              curr.each {|c| c << elem }
              elem << elem if $2 != '?'
              curr = $2 == '+' ? [elem] : (curr << elem)
            else
              elem = Element.new(self, elem)
              curr.each {|c| c << elem }
              curr = [elem]
            end
          end
          elem = Value([])
          curr.each {|c| c << elem }
          start
        else
          raise ArgumentError, "Invalid grammar rule '#{rule.inspect}'"
        end
      end

      def const_missing(name)
        const_set(name, Root.new(self, name))
      end
    end
  end
end
