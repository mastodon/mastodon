# -*- coding: utf-8 -*-

require "helper"

module Nokogiri
  module CSS
    class Tokenizer
      alias :scan :scan_setup
    end
  end
end

module Nokogiri
  module CSS
    class TestTokenizer < Nokogiri::TestCase
      def setup
        super
        @scanner = Nokogiri::CSS::Tokenizer.new
      end

      def test_has
        @scanner.scan("a:has(b)")
        assert_tokens(
          [[:IDENT, "a"], [":", ":"], [:HAS, "has("], [:IDENT, "b"], [:RPAREN, ")"]],
          @scanner)
      end

      def test_unicode
        @scanner.scan("a日本語")
        assert_tokens([[:IDENT, 'a日本語']], @scanner)
      end

      def test_tokenize_bad_single_quote
        @scanner.scan("'")
        assert_tokens([["'", "'"]], @scanner)
      end

      def test_not_equal
        @scanner.scan("h1[a!='Tender Lovemaking']")
        assert_tokens([ [:IDENT, 'h1'],
                        [:LSQUARE, '['],
                        [:IDENT, 'a'],
                        [:NOT_EQUAL, '!='],
                        [:STRING, "'Tender Lovemaking'"],
                        [:RSQUARE, ']'],
        ], @scanner)
      end

      def test_negation
        @scanner.scan("p:not(.a)")
        assert_tokens([ [:IDENT, 'p'],
                        [:NOT, ':not('],
                        ['.', '.'],
                        [:IDENT, 'a'],
                        [:RPAREN, ')'],
        ], @scanner)
      end

      def test_function
        @scanner.scan("script comment()")
        assert_tokens([ [:IDENT, 'script'],
                        [:S, ' '],
                        [:FUNCTION, 'comment('],
                        [:RPAREN, ')'],
        ], @scanner)
      end

      def test_preceding_selector
        @scanner.scan("E ~ F")
        assert_tokens([ [:IDENT, 'E'],
                        [:TILDE, ' ~ '],
                        [:IDENT, 'F'],
        ], @scanner)
      end

      def test_scan_attribute_string
        @scanner.scan("h1[a='Tender Lovemaking']")
        assert_tokens([ [:IDENT, 'h1'],
                        [:LSQUARE, '['],
                        [:IDENT, 'a'],
                        [:EQUAL, '='],
                        [:STRING, "'Tender Lovemaking'"],
                        [:RSQUARE, ']'],
        ], @scanner)
        @scanner.scan('h1[a="Tender Lovemaking"]')
        assert_tokens([ [:IDENT, 'h1'],
                        [:LSQUARE, '['],
                        [:IDENT, 'a'],
                        [:EQUAL, '='],
                        [:STRING, '"Tender Lovemaking"'],
                        [:RSQUARE, ']'],
        ], @scanner)
      end

      def test_scan_id
        @scanner.scan('#foo')
        assert_tokens([ [:HASH, '#foo'] ], @scanner)
      end

      def test_scan_pseudo
        @scanner.scan('a:visited')
        assert_tokens([ [:IDENT, 'a'],
                        [':', ':'],
                        [:IDENT, 'visited']
        ], @scanner)
      end

      def test_scan_star
        @scanner.scan('*')
        assert_tokens([ ['*', '*'], ], @scanner)
      end

      def test_scan_class
        @scanner.scan('x.awesome')
        assert_tokens([ [:IDENT, 'x'],
                        ['.', '.'],
                        [:IDENT, 'awesome'],
        ], @scanner)
      end

      def test_scan_greater
        @scanner.scan('x > y')
        assert_tokens([ [:IDENT, 'x'],
                        [:GREATER, ' > '],
                        [:IDENT, 'y']
        ], @scanner)
      end

      def test_scan_slash
        @scanner.scan('x/y')
        assert_tokens([ [:IDENT, 'x'],
                        [:SLASH, '/'],
                        [:IDENT, 'y']
        ], @scanner)
      end

      def test_scan_doubleslash
        @scanner.scan('x//y')
        assert_tokens([ [:IDENT, 'x'],
                        [:DOUBLESLASH, '//'],
                        [:IDENT, 'y']
        ], @scanner)
      end

      def test_scan_function_selector
        @scanner.scan('x:eq(0)')
        assert_tokens([ [:IDENT, 'x'],
                        [':', ':'],
                        [:FUNCTION, 'eq('],
                        [:NUMBER, "0"],
                        [:RPAREN, ')'],
        ], @scanner)
      end

      def test_scan_nth
        @scanner.scan('x:nth-child(5n+3)')
        assert_tokens([ [:IDENT, 'x'],
                        [':', ':'],
                        [:FUNCTION, 'nth-child('],
                        [:NUMBER, '5'],
                        [:IDENT, 'n'],
                        [:PLUS, '+'],
                        [:NUMBER, '3'],
                        [:RPAREN, ')'],
        ], @scanner)

        @scanner.scan('x:nth-child(-1n+3)')
        assert_tokens([ [:IDENT, 'x'],
                        [':', ':'],
                        [:FUNCTION, 'nth-child('],
                        [:NUMBER, '-1'],
                        [:IDENT, 'n'],
                        [:PLUS, '+'],
                        [:NUMBER, '3'],
                        [:RPAREN, ')'],
        ], @scanner)

        @scanner.scan('x:nth-child(-n+3)')
        assert_tokens([ [:IDENT, 'x'],
                        [':', ':'],
                        [:FUNCTION, 'nth-child('],
                        [:IDENT, '-n'],
                        [:PLUS, '+'],
                        [:NUMBER, '3'],
                        [:RPAREN, ')'],
        ], @scanner)
      end

      def test_significant_space
        @scanner.scan('x :first-child [a] [b]')
        assert_tokens([ [:IDENT, 'x'],
                        [:S, ' '],
                        [':', ':'],
                        [:IDENT, 'first-child'],
                        [:S, ' '],
                        [:LSQUARE, '['],
                        [:IDENT, 'a'],
                        [:RSQUARE, ']'],
                        [:S, ' '],
                        [:LSQUARE, '['],
                        [:IDENT, 'b'],
                        [:RSQUARE, ']'],
        ], @scanner)
      end

      def assert_tokens(tokens, scanner)
        toks = []
        while tok = @scanner.next_token
          toks << tok
        end
        assert_equal(tokens, toks)
      end
    end
  end
end
