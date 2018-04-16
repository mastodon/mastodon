require "helper"

module Nokogiri
  module XML
    class TestSyntaxError < Nokogiri::TestCase
      def test_new
        error = Nokogiri::XML::SyntaxError.new 'hello'
        assert_equal 'hello', error.message
      end

      def test_line_column_level_libxml
        skip unless Nokogiri.uses_libxml?

        bad_doc = Nokogiri::XML('test')
        error = bad_doc.errors.first

        assert_equal "1:1: FATAL: Start tag expected, '<' not found", error.message
        assert_equal 1, error.line
        assert_equal 1, error.column
        assert_equal 3, error.level
      end

      def test_line_column_level_jruby
        skip unless Nokogiri.jruby?

        bad_doc = Nokogiri::XML('<root>test</bar>')
        error = bad_doc.errors.first

        assert_equal "The element type \"root\" must be terminated by the matching end-tag \"</root>\".", error.message
        assert_equal nil, error.line
        assert_equal nil, error.column
        assert_equal nil, error.level
      end
    end
  end
end
