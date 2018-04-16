# -*- coding: utf-8 -*-
require "helper"

module Nokogiri
  module HTML
    class TestNodeEncoding < Nokogiri::TestCase
      def setup
        super
        @html = Nokogiri::HTML(File.open(NICH_FILE, "rb"))
      end

      def test_get_attribute
        node = @html.css('a').first
        assert_equal 'UTF-8', node['href'].encoding.name
      end

      def test_text_encoding_is_utf_8
        assert_equal 'UTF-8', @html.text.encoding.name
      end

      def test_serialize_encoding_html
        assert_equal @html.encoding.downcase,
          @html.serialize.encoding.name.downcase

        @doc = Nokogiri::HTML(@html.serialize)
        assert_equal @html.serialize, @doc.serialize
      end

      def test_default_encoding
        doc = Nokogiri::HTML(nil)
        assert_nil doc.encoding
        assert_equal 'UTF-8', doc.serialize.encoding.name
      end

      def test_encode_special_chars
        foo = @html.css('a').first.encode_special_chars('foo')
        assert_equal 'UTF-8', foo.encoding.name
      end

      def test_content
        node = @html.css('a').first
        assert_equal 'UTF-8', node.content.encoding.name
      end

      def test_name
        node = @html.css('a').first
        assert_equal 'UTF-8', node.name.encoding.name
      end

      def test_path
        node = @html.css('a').first
        assert_equal 'UTF-8', node.path.encoding.name
      end

      def test_inner_html
        doc = Nokogiri::HTML File.open(SHIFT_JIS_HTML, 'rb')

        hello = "こんにちは"

        contents = doc.at('h2').inner_html
        assert_equal doc.encoding, contents.encoding.name
        assert_match hello.encode('Shift_JIS'), contents

        contents = doc.at('h2').inner_html(:encoding => 'UTF-8')
        assert_match hello, contents

        doc.encoding = 'UTF-8'
        contents = doc.at('h2').inner_html
        assert_match hello, contents
      end

      def test_encoding_GH_1113
        doc = Nokogiri::HTML::Document.new
        hex = '<p>&#x1f340;</p>'
        decimal = '<p>&#127808;</p>'
        encoded = '<p>🍀</p>'

        doc.encoding = 'UTF-8'
        [hex, decimal, encoded].each do |document|
          assert_equal encoded, doc.fragment(document).to_s
        end

        doc.encoding = 'US-ASCII'
        expected = Nokogiri.jruby? ? hex : decimal
        [hex, decimal].each do |document|
          assert_equal expected, doc.fragment(document).to_s
        end
      end
    end
  end
end
