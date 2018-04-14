require "helper"

module Nokogiri
  module XML
    class TestCDATA < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
      end

      def test_cdata_node
        name = @xml.xpath('//employee[2]/name').first
        assert cdata = name.children[1]
        assert cdata.cdata?
        assert_equal '#cdata-section', cdata.name
      end

      def test_new
        node = CDATA.new(@xml, "foo")
        assert_equal "foo", node.content

        node = CDATA.new(@xml.root, "foo")
        assert_equal "foo", node.content
      end

      def test_new_with_nil
        node = CDATA.new(@xml, nil)
        assert_equal nil, node.content
      end

      def test_new_with_non_string
        assert_raises(TypeError) do
          CDATA.new(@xml, 1.234)
        end
      end

      def test_lots_of_new_cdata
        assert 100.times { CDATA.new(@xml, "asdfasdf") }
      end

      def test_content=
        node = CDATA.new(@xml, 'foo')
        assert_equal('foo', node.content)

        node.content = '& <foo> &amp;'
        assert_equal('& <foo> &amp;', node.content)
        assert_equal('<![CDATA[& <foo> &amp;]]>', node.to_xml)

        node.content = 'foo ]]> bar'
        assert_equal('foo ]]> bar', node.content)
      end
    end
  end
end
