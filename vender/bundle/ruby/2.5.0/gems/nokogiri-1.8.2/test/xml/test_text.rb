require "helper"

module Nokogiri
  module XML
    class TestText < Nokogiri::TestCase
      def test_css_path
        doc  = Nokogiri.XML "<root> foo <a>something</a> bar bazz </root>"
        node = doc.root.children[2]
        assert_instance_of Nokogiri::XML::Text, node
        assert_equal node, doc.at_css(node.css_path)
      end

      def test_inspect
        node = Text.new('hello world', Document.new)
        assert_equal "#<#{node.class.name}:#{sprintf("0x%x",node.object_id)} #{node.text.inspect}>", node.inspect
      end

      def test_new
        node = Text.new('hello world', Document.new)
        assert node
        assert_equal('hello world', node.content)
        assert_instance_of Nokogiri::XML::Text, node
      end

      def test_lots_of_text
        100.times { Text.new('hello world', Document.new) }
      end

      def test_new_without_document
        doc = Document.new
        node = Nokogiri::XML::Element.new('foo', doc)

        assert Text.new('hello world', node)
      end

      def test_content=
        node = Text.new('foo', Document.new)
        assert_equal('foo', node.content)
        node.content = '& <foo> &amp;'
        assert_equal('& <foo> &amp;', node.content)
        assert_equal('&amp; &lt;foo&gt; &amp;amp;', node.to_xml)
      end

      def test_add_child
        node = Text.new('foo', Document.new)
        if Nokogiri.jruby?
          exc = RuntimeError
        else
          exc = ArgumentError
        end
        assert_raises(exc) {
          node.add_child Text.new('bar', Document.new)
        }
        assert_raises(exc) {
          node << Text.new('bar', Document.new)
        }
      end
    end
  end
end
