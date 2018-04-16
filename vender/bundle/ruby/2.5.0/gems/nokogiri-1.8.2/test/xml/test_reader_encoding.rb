# -*- coding: utf-8 -*-
require "helper"

module Nokogiri
  module XML
    class TestReaderEncoding < Nokogiri::TestCase
      def setup
        super
        @reader = Nokogiri::XML::Reader(
          File.read(XML_FILE),
          XML_FILE,
          'UTF-8'
        )
      end

      def test_attribute_at
        @reader.each do |node|
          next unless attribute = node.attribute_at(0)
          assert_equal @reader.encoding, attribute.encoding.name
        end
      end

      def test_attributes
        @reader.each do |node|
          node.attributes.each do |k,v|
            assert_equal @reader.encoding, k.encoding.name
            assert_equal @reader.encoding, v.encoding.name
          end
        end
      end

      def test_attribute
        xml = <<-eoxml
          <x xmlns:tenderlove='http://tenderlovemaking.com/'>
            <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
          </x>
        eoxml
        reader = Nokogiri::XML::Reader(xml, nil, 'UTF-8')
        reader.each do |node|
          next unless attribute = node.attribute('awesome')
          assert_equal reader.encoding, attribute.encoding.name
        end
      end

      def test_xml_version
        @reader.each do |node|
          next unless version = node.xml_version
          assert_equal @reader.encoding, version.encoding.name
        end
      end

      def test_lang
        xml = <<-eoxml
          <awesome>
            <p xml:lang="en">The quick brown fox jumps over the lazy dog.</p>
            <p xml:lang="ja">日本語が上手です</p>
          </awesome>
        eoxml

        reader = Nokogiri::XML::Reader(xml, nil, 'UTF-8')
        reader.each do |node|
          next unless lang = node.lang
          assert_equal reader.encoding, lang.encoding.name
        end
      end

      def test_value
        called = false
        @reader.each do |node|
          next unless value = node.value
          assert_equal @reader.encoding, value.encoding.name
          called = true
        end
        assert called
      end

      def test_prefix
        xml = <<-eoxml
          <x xmlns:edi='http://ecommerce.example.org/schema'>
            <edi:foo>hello</edi:foo>
          </x>
        eoxml
        reader = Nokogiri::XML::Reader(xml, nil, 'UTF-8')
        reader.each do |node|
          next unless prefix = node.prefix
          assert_equal reader.encoding, prefix.encoding.name
        end
      end

      def test_ns_uri
        xml = <<-eoxml
          <x xmlns:edi='http://ecommerce.example.org/schema'>
            <edi:foo>hello</edi:foo>
          </x>
        eoxml
        reader = Nokogiri::XML::Reader(xml, nil, 'UTF-8')
        reader.each do |node|
          next unless uri = node.namespace_uri
          assert_equal reader.encoding, uri.encoding.name
        end
      end

      def test_local_name
        xml = <<-eoxml
          <x xmlns:edi='http://ecommerce.example.org/schema'>
            <edi:foo>hello</edi:foo>
          </x>
        eoxml
        reader = Nokogiri::XML::Reader(xml, nil, 'UTF-8')
        reader.each do |node|
          next unless lname = node.local_name
          assert_equal reader.encoding, lname.encoding.name
        end
      end

      def test_name
        @reader.each do |node|
          next unless name = node.name
          assert_equal @reader.encoding, name.encoding.name
        end
      end

      def test_value_lookup_segfault
        skip("JRuby doesn't do GC.") if Nokogiri.jruby?
        stress_memory_while do
          while node = @reader.read
            nodes = node.send(:attr_nodes)
            nodes.first.name if nodes.first
          end
        end
      end
    end
  end
end
