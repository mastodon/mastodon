require "helper"

module Nokogiri
  module CSS
    class TestParser < Nokogiri::TestCase
      def setup
        super
        @parser = Nokogiri::CSS::Parser.new
        @parser_with_ns = Nokogiri::CSS::Parser.new({
          "xmlns" => "http://default.example.com/",
          "hoge" => "http://hoge.example.com/",
        })
      end

      def test_extra_single_quote
        assert_raises(CSS::SyntaxError) { @parser.parse("'") }
      end

      def test_syntax_error_raised
        assert_raises(CSS::SyntaxError) { @parser.parse("a[x=]") }
      end

      def test_function_and_pseudo
        assert_xpath '//child::text()[position() = 99]', @parser.parse('text():nth-of-type(99)')
      end

      def test_find_by_type
        ast = @parser.parse("a:nth-child(2)").first
        matches = ast.find_by_type(
          [:CONDITIONAL_SELECTOR,
            [:ELEMENT_NAME],
            [:PSEUDO_CLASS,
              [:FUNCTION]
            ]
          ]
        )
        assert_equal(1, matches.length)
        assert_equal(ast, matches.first)
      end

      def test_to_type
        ast = @parser.parse("a:nth-child(2)").first
        assert_equal(
          [:CONDITIONAL_SELECTOR,
            [:ELEMENT_NAME],
            [:PSEUDO_CLASS,
              [:FUNCTION]
            ]
          ], ast.to_type
        )
      end

      def test_to_a
        asts = @parser.parse("a:nth-child(2)")
        assert_equal(
          [:CONDITIONAL_SELECTOR,
            [:ELEMENT_NAME, ["a"]],
            [:PSEUDO_CLASS,
              [:FUNCTION, ["nth-child("], ["2"]]
            ]
          ], asts.first.to_a
        )
      end

      def test_has
        assert_xpath  "//a[b]", @parser.parse("a:has(b)")
        assert_xpath  "//a[b/c]", @parser.parse("a:has(b > c)")
      end

      def test_dashmatch
        assert_xpath  "//a[@class = 'bar' or starts-with(@class, concat('bar', '-'))]",
                      @parser.parse("a[@class|='bar']")
        assert_xpath  "//a[@class = 'bar' or starts-with(@class, concat('bar', '-'))]",
                      @parser.parse("a[@class |= 'bar']")
      end

      def test_includes
        assert_xpath  "//a[contains(concat(\" \", @class, \" \"),concat(\" \", 'bar', \" \"))]",
                      @parser.parse("a[@class~='bar']")
        assert_xpath  "//a[contains(concat(\" \", @class, \" \"),concat(\" \", 'bar', \" \"))]",
                      @parser.parse("a[@class ~= 'bar']")
      end

      def test_function_with_arguments
        assert_xpath  "//a[count(preceding-sibling::*) = 1]",
                      @parser.parse("a[2]")
        assert_xpath  "//a[count(preceding-sibling::*) = 1]",
                      @parser.parse("a:nth-child(2)")
      end

      def test_carrot
        assert_xpath  "//a[starts-with(@id, 'Boing')]",
                      @parser.parse("a[id^='Boing']")
        assert_xpath  "//a[starts-with(@id, 'Boing')]",
                      @parser.parse("a[id ^= 'Boing']")
      end

      def test_suffix_match
        assert_xpath "//a[substring(@id, string-length(@id) - string-length('Boing') + 1, string-length('Boing')) = 'Boing']",
                      @parser.parse("a[id$='Boing']")
        assert_xpath "//a[substring(@id, string-length(@id) - string-length('Boing') + 1, string-length('Boing')) = 'Boing']",
                      @parser.parse("a[id $= 'Boing']")
      end

      def test_attributes_with_at
        ## This is non standard CSS
        assert_xpath  "//a[@id = 'Boing']",
                      @parser.parse("a[@id='Boing']")
        assert_xpath  "//a[@id = 'Boing']",
                      @parser.parse("a[@id = 'Boing']")
      end

      def test_attributes_with_at_and_stuff
        ## This is non standard CSS
        assert_xpath  "//a[@id = 'Boing']//div",
                      @parser.parse("a[@id='Boing'] div")
      end

      def test_not_equal
        ## This is non standard CSS
        assert_xpath  "//a[child::text() != 'Boing']",
                      @parser.parse("a[text()!='Boing']")
        assert_xpath  "//a[child::text() != 'Boing']",
                      @parser.parse("a[text() != 'Boing']")
      end

      def test_function
        ## This is non standard CSS
        assert_xpath  "//a[child::text()]",
                      @parser.parse("a[text()]")

        ## This is non standard CSS
        assert_xpath  "//child::text()",
                      @parser.parse("text()")

        ## This is non standard CSS
        assert_xpath  "//a[contains(child::text(), 'Boing')]",
                      @parser.parse("a[text()*='Boing']")
        assert_xpath  "//a[contains(child::text(), 'Boing')]",
                      @parser.parse("a[text() *= 'Boing']")

        ## This is non standard CSS
        assert_xpath  "//script//comment()",
                      @parser.parse("script comment()")
      end

      def test_nonstandard_nth_selectors
        ## These are non standard CSS
        assert_xpath '//a[position() = 1]',             @parser.parse('a:first()')
        assert_xpath '//a[position() = 1]',             @parser.parse('a:first') # no parens
        assert_xpath '//a[position() = 99]',            @parser.parse('a:eq(99)')
        assert_xpath '//a[position() = 99]',            @parser.parse('a:nth(99)')
        assert_xpath '//a[position() = last()]',        @parser.parse('a:last()')
        assert_xpath '//a[position() = last()]',        @parser.parse('a:last') # no parens
        assert_xpath '//a[node()]',                     @parser.parse('a:parent')
      end

      def test_standard_nth_selectors
        assert_xpath '//a[position() = 1]',             @parser.parse('a:first-of-type()')
        assert_xpath '//a[position() = 1]',             @parser.parse('a:first-of-type') # no parens
        assert_xpath "//a[contains(concat(' ', normalize-space(@class), ' '), ' b ')][position() = 1]",
                     @parser.parse('a.b:first-of-type') # no parens
        assert_xpath '//a[position() = 99]',            @parser.parse('a:nth-of-type(99)')
        assert_xpath "//a[contains(concat(' ', normalize-space(@class), ' '), ' b ')][position() = 99]",
                     @parser.parse('a.b:nth-of-type(99)')
        assert_xpath '//a[position() = last()]',        @parser.parse('a:last-of-type()')
        assert_xpath '//a[position() = last()]',        @parser.parse('a:last-of-type') # no parens
        assert_xpath "//a[contains(concat(' ', normalize-space(@class), ' '), ' b ')][position() = last()]",
                     @parser.parse('a.b:last-of-type') # no parens
        assert_xpath '//a[position() = last()]',        @parser.parse('a:nth-last-of-type(1)')
        assert_xpath '//a[position() = last() - 98]',   @parser.parse('a:nth-last-of-type(99)')
        assert_xpath "//a[contains(concat(' ', normalize-space(@class), ' '), ' b ')][position() = last() - 98]",
                     @parser.parse('a.b:nth-last-of-type(99)')
      end

      def test_nth_child_selectors
        assert_xpath '//a[count(preceding-sibling::*) = 0]',  @parser.parse('a:first-child')
        assert_xpath '//a[count(preceding-sibling::*) = 98]', @parser.parse('a:nth-child(99)')
        assert_xpath '//a[count(following-sibling::*) = 0]',  @parser.parse('a:last-child')
        assert_xpath '//a[count(following-sibling::*) = 0]',  @parser.parse('a:nth-last-child(1)')
        assert_xpath '//a[count(following-sibling::*) = 98]', @parser.parse('a:nth-last-child(99)')
      end

      def test_miscellaneous_selectors
        assert_xpath '//a[count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0]',  @parser.parse('a:only-child')
        assert_xpath '//a[last() = 1]', @parser.parse('a:only-of-type')
        assert_xpath '//a[not(node())]', @parser.parse('a:empty')
      end

      def test_nth_a_n_plus_b
        assert_xpath '//a[(position() mod 2) = 0]', @parser.parse('a:nth-of-type(2n)')
        assert_xpath '//a[(position() >= 1) and (((position()-1) mod 2) = 0)]', @parser.parse('a:nth-of-type(2n+1)')
        assert_xpath '//a[(position() mod 2) = 0]', @parser.parse('a:nth-of-type(even)')
        assert_xpath '//a[(position() >= 1) and (((position()-1) mod 2) = 0)]', @parser.parse('a:nth-of-type(odd)')
        assert_xpath '//a[(position() >= 3) and (((position()-3) mod 4) = 0)]', @parser.parse('a:nth-of-type(4n+3)')
        assert_xpath '//a[position() <= 3]', @parser.parse('a:nth-of-type(-1n+3)')
        assert_xpath '//a[position() <= 3]', @parser.parse('a:nth-of-type(-n+3)')
        assert_xpath '//a[position() >= 3]', @parser.parse('a:nth-of-type(1n+3)')
        assert_xpath '//a[position() >= 3]', @parser.parse('a:nth-of-type(n+3)')

        assert_xpath '//a[((last()-position()+1) mod 2) = 0]', @parser.parse('a:nth-last-of-type(2n)')
        assert_xpath '//a[((last()-position()+1) >= 1) and ((((last()-position()+1)-1) mod 2) = 0)]', @parser.parse('a:nth-last-of-type(2n+1)')
        assert_xpath '//a[((last()-position()+1) mod 2) = 0]', @parser.parse('a:nth-last-of-type(even)')
        assert_xpath '//a[((last()-position()+1) >= 1) and ((((last()-position()+1)-1) mod 2) = 0)]', @parser.parse('a:nth-last-of-type(odd)')
        assert_xpath '//a[((last()-position()+1) >= 3) and ((((last()-position()+1)-3) mod 4) = 0)]', @parser.parse('a:nth-last-of-type(4n+3)')
        assert_xpath '//a[(last()-position()+1) <= 3]', @parser.parse('a:nth-last-of-type(-1n+3)')
        assert_xpath '//a[(last()-position()+1) <= 3]', @parser.parse('a:nth-last-of-type(-n+3)')
        assert_xpath '//a[(last()-position()+1) >= 3]', @parser.parse('a:nth-last-of-type(1n+3)')
        assert_xpath '//a[(last()-position()+1) >= 3]', @parser.parse('a:nth-last-of-type(n+3)')
      end

      def test_preceding_selector
        assert_xpath  "//E/following-sibling::F",
                      @parser.parse("E ~ F")

        assert_xpath  "//E/following-sibling::F//G",
                      @parser.parse("E ~ F G")
      end

      def test_direct_preceding_selector
        assert_xpath  "//E/following-sibling::*[1]/self::F",
                      @parser.parse("E + F")

        assert_xpath  "//E/following-sibling::*[1]/self::F//G",
                      @parser.parse("E + F G")
      end

      def test_child_selector
        assert_xpath("//a//b/i", @parser.parse('a b>i'))
        assert_xpath("//a//b/i", @parser.parse('a b > i'))
        assert_xpath("//a/b/i", @parser.parse('a > b > i'))
      end

      def test_prefixless_child_selector
        assert_xpath("./a", @parser.parse('>a'))
        assert_xpath("./a", @parser.parse('> a'))
        assert_xpath("./a//b/i", @parser.parse('>a b>i'))
        assert_xpath("./a/b/i", @parser.parse('> a > b > i'))
      end

      def test_prefixless_preceding_sibling_selector
        assert_xpath("./following-sibling::a", @parser.parse('~a'))
        assert_xpath("./following-sibling::a", @parser.parse('~ a'))
        assert_xpath("./following-sibling::a//b/following-sibling::i", @parser.parse('~a b~i'))
        assert_xpath("./following-sibling::a//b/following-sibling::i", @parser.parse('~ a b ~ i'))
      end

      def test_prefixless_direct_adjacent_selector
        assert_xpath("./following-sibling::*[1]/self::a", @parser.parse('+a'))
        assert_xpath("./following-sibling::*[1]/self::a", @parser.parse('+ a'))
        assert_xpath("./following-sibling::*[1]/self::a/following-sibling::*[1]/self::b", @parser.parse('+a+b'))
        assert_xpath("./following-sibling::*[1]/self::a/following-sibling::*[1]/self::b", @parser.parse('+ a + b'))
      end

      def test_attribute
        assert_xpath  "//h1[@a = 'Tender Lovemaking']",
                      @parser.parse("h1[a='Tender Lovemaking']")
      end

      def test_id
        assert_xpath "//*[@id = 'foo']", @parser.parse('#foo')
        assert_xpath "//*[@id = 'escape:needed,']", @parser.parse('#escape\:needed\,')
        assert_xpath "//*[@id = 'escape:needed,']", @parser.parse('#escape\3Aneeded\,')
        assert_xpath "//*[@id = 'escape:needed,']", @parser.parse('#escape\3A needed\2C')
        assert_xpath "//*[@id = 'escape:needed']", @parser.parse('#escape\00003Aneeded')
      end

      def test_pseudo_class_no_ident
        assert_xpath "//*[link(.)]", @parser.parse(':link')
      end

      def test_pseudo_class
        assert_xpath "//a[link(.)]", @parser.parse('a:link')
        assert_xpath "//a[visited(.)]", @parser.parse('a:visited')
        assert_xpath "//a[hover(.)]", @parser.parse('a:hover')
        assert_xpath "//a[active(.)]", @parser.parse('a:active')
        assert_xpath  "//a[active(.) and contains(concat(' ', normalize-space(@class), ' '), ' foo ')]",
                      @parser.parse('a:active.foo')
      end

      def test_significant_space
        assert_xpath "//x//*[count(preceding-sibling::*) = 0]//*[@a]//*[@b]", @parser.parse("x :first-child [a] [b]")
        assert_xpath "//*[@a]//*[@b]", @parser.parse(" [a] [b]")
      end

      def test_star
        assert_xpath "//*", @parser.parse('*')
        assert_xpath "//*[contains(concat(' ', normalize-space(@class), ' '), ' pastoral ')]",
                      @parser.parse('*.pastoral')
      end

      def test_class
        assert_xpath  "//*[contains(concat(' ', normalize-space(@class), ' '), ' a ') and contains(concat(' ', normalize-space(@class), ' '), ' b ')]",
                      @parser.parse('.a.b')
        assert_xpath  "//*[contains(concat(' ', normalize-space(@class), ' '), ' awesome ')]",
                      @parser.parse('.awesome')
        assert_xpath  "//foo[contains(concat(' ', normalize-space(@class), ' '), ' awesome ')]",
                      @parser.parse('foo.awesome')
        assert_xpath  "//foo//*[contains(concat(' ', normalize-space(@class), ' '), ' awesome ')]",
                      @parser.parse('foo .awesome')
        assert_xpath  "//foo//*[contains(concat(' ', normalize-space(@class), ' '), ' awe.some ')]",
                      @parser.parse('foo .awe\.some')
      end

      def test_bare_not
        assert_xpath "//*[not(contains(concat(' ', normalize-space(@class), ' '), ' a '))]",
                     @parser.parse(':not(.a)')
      end

      def test_not_so_simple_not
        assert_xpath "//*[@id = 'p' and not(contains(concat(' ', normalize-space(@class), ' '), ' a '))]",
                     @parser.parse('#p:not(.a)')
        assert_xpath "//p[contains(concat(' ', normalize-space(@class), ' '), ' a ') and not(contains(concat(' ', normalize-space(@class), ' '), ' b '))]",
                     @parser.parse('p.a:not(.b)')
        assert_xpath "//p[@a = 'foo' and not(contains(concat(' ', normalize-space(@class), ' '), ' b '))]",
                     @parser.parse("p[a='foo']:not(.b)")
      end

      def test_multiple_not
        assert_xpath "//p[not(contains(concat(' ', normalize-space(@class), ' '), ' a ')) and not(contains(concat(' ', normalize-space(@class), ' '), ' b ')) and not(contains(concat(' ', normalize-space(@class), ' '), ' c '))]",
                    @parser.parse("p:not(.a):not(.b):not(.c)")
      end

      def test_ident
        assert_xpath '//x', @parser.parse('x')
      end

      def test_parse_space
        assert_xpath '//x//y', @parser.parse('x y')
      end

      def test_parse_descendant
        assert_xpath '//x/y', @parser.parse('x > y')
      end

      def test_parse_slash
        ## This is non standard CSS
        assert_xpath '//x/y', @parser.parse('x/y')
      end

      def test_parse_doubleslash
        ## This is non standard CSS
        assert_xpath '//x//y', @parser.parse('x//y')
      end

      def test_multi_path
        assert_xpath ['//x/y', '//y/z'], @parser.parse('x > y, y > z')
        assert_xpath ['//x/y', '//y/z'], @parser.parse('x > y,y > z')
        ###
        # TODO: should we make this work?
        # assert_xpath ['//x/y', '//y/z'], @parser.parse('x > y | y > z')
      end

      def test_attributes_with_namespace
        ## Default namespace is not applied to attributes.
        ## So this must be @class, not @xmlns:class.
        assert_xpath "//xmlns:a[@class = 'bar']", @parser_with_ns.parse("a[class='bar']")
        assert_xpath "//xmlns:a[@hoge:class = 'bar']", @parser_with_ns.parse("a[hoge|class='bar']")
      end

      def assert_xpath expecteds, asts
        expecteds = [expecteds].flatten
        expecteds.zip(asts).each do |expected, actual|
          assert_equal expected, actual.to_xpath
        end
      end
    end
  end
end
