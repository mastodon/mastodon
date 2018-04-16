require "helper"

module Nokogiri
  module XML
    class TestAttr < Nokogiri::TestCase
      def test_new
        100.times {
          doc = Nokogiri::XML::Document.new
          assert doc
          assert Nokogiri::XML::Attr.new(doc, 'foo')
        }
      end

      def test_new_raises_argerror_on_nondocument
        document = Nokogiri::XML "<root><foo/></root>"
        assert_raises ArgumentError do
          Nokogiri::XML::Attr.new document.at_css("foo"), "bar"
        end
      end

      def test_content=
        xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
        address = xml.xpath('//address')[3]
        street = address.attributes['street']
        street.content = "Y&ent1;"
        assert_equal "Y&ent1;", street.value
      end

      def test_value=
        xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
        address = xml.xpath('//address')[3]
        street = address.attributes['street']
        street.value = "Y&ent1;"
        assert_equal "Y&ent1;", street.value
      end

      def test_unlink # aliased as :remove
        xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
        address = xml.xpath('/staff/employee/address').first
        assert_equal 'Yes', address['domestic']

        attr = address.attribute_nodes.first
        return_val = attr.unlink
        assert_nil address['domestic']
        assert_equal attr, return_val
      end

      def test_parsing_attribute_namespace
        doc = Nokogiri::XML <<-EOXML
<root xmlns='http://google.com/' xmlns:f='http://flavorjon.es/'>
  <div f:myattr='foo'></div>
</root>
        EOXML

        node = doc.at_css "div"
        attr = node.attributes["myattr"]
        assert_equal "http://flavorjon.es/", attr.namespace.href
      end

      def test_setting_attribute_namespace
        doc = Nokogiri::XML <<-EOXML
<root xmlns='http://google.com/' xmlns:f='http://flavorjon.es/'>
  <div f:myattr='foo'></div>
</root>
        EOXML

        node = doc.at_css "div"
        attr = node.attributes["myattr"]
        attr.add_namespace("fizzle", "http://fizzle.com/")
        assert_equal "http://fizzle.com/", attr.namespace.href
      end
    end
  end
end
