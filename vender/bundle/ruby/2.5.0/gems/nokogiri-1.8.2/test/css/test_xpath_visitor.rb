require "helper"

module Nokogiri
  module CSS
    class TestXPathVisitor < Nokogiri::TestCase
      def setup
        super
        @parser = Nokogiri::CSS::Parser.new
      end

      def test_not_simple_selector
        assert_xpath('//ol/*[not(self::li)]', @parser.parse('ol > *:not(li)'))
      end

      def test_not_last_child
        assert_xpath('//ol/*[not(count(following-sibling::*) = 0)]',
          @parser.parse('ol > *:not(:last-child)'))
      end

      def test_not_only_child
        assert_xpath('//ol/*[not(count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0)]',
          @parser.parse('ol > *:not(:only-child)'))
      end

      def test_function_calls_allow_at_params
        assert_xpath("//a[foo(., @href)]", @parser.parse('a:foo(@href)'))
        assert_xpath("//a[foo(., @a, b)]", @parser.parse('a:foo(@a, b)'))
        assert_xpath("//a[foo(., a, 10)]", @parser.parse('a:foo(a, 10)'))
      end

      def test_namespace_conversion
        assert_xpath("//aaron:a", @parser.parse('aaron|a'))
        assert_xpath("//a", @parser.parse('|a'))
      end

      def test_namespaced_attribute_conversion
        assert_xpath("//a[@flavorjones:href]", @parser.parse('a[flavorjones|href]'))
        assert_xpath("//a[@href]", @parser.parse('a[|href]'))
        assert_xpath("//*[@flavorjones:href]", @parser.parse('*[flavorjones|href]'))
      end

      def test_unknown_psuedo_classes_get_pushed_down
        assert_xpath("//a[aaron(.)]", @parser.parse('a:aaron'))
      end

      def test_unknown_functions_get_dot_plus_args
        assert_xpath("//a[aaron(.)]", @parser.parse('a:aaron()'))
        assert_xpath("//a[aaron(., 12)]", @parser.parse('a:aaron(12)'))
        assert_xpath("//a[aaron(., 12, 1)]", @parser.parse('a:aaron(12, 1)'))
      end

      def test_class_selectors
        assert_xpath  "//*[contains(concat(' ', normalize-space(@class), ' '), ' red ')]",
                      @parser.parse(".red")
      end

      def test_pipe
        assert_xpath  "//a[@id = 'Boing' or starts-with(@id, concat('Boing', '-'))]",
                      @parser.parse("a[id|='Boing']")
      end

      def test_custom_functions
        visitor = Class.new(XPathVisitor) do
          attr_accessor :awesome
          def visit_function_aaron node
            @awesome = true
            'aaron() = 1'
          end
        end.new
        ast = @parser.parse('a:aaron()').first
        assert_equal 'a[aaron() = 1]', visitor.accept(ast)
        assert visitor.awesome
      end

      def test_custom_psuedo_classes
        visitor = Class.new(XPathVisitor) do
          attr_accessor :awesome
          def visit_pseudo_class_aaron node
            @awesome = true
            'aaron() = 1'
          end
        end.new
        ast = @parser.parse('a:aaron').first
        assert_equal 'a[aaron() = 1]', visitor.accept(ast)
        assert visitor.awesome
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
