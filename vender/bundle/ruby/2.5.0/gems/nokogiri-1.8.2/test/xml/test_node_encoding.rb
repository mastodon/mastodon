# encoding: UTF-8
require "helper"

module Nokogiri
  module XML
    class TestNodeEncoding < Nokogiri::TestCase
      def test_serialize_encoding_xml
        @xml = Nokogiri::XML(File.open(SHIFT_JIS_XML))
        assert_equal @xml.encoding.downcase,
          @xml.serialize.encoding.name.downcase

        @doc = Nokogiri::XML(@xml.serialize)
        assert_equal @xml.serialize, @doc.serialize
      end

      def test_default_encoding
        doc = Nokogiri::XML(VEHICLE_XML)
        assert_nil doc.encoding
        assert_equal 'UTF-8', doc.serialize.encoding.name
      end

      def test_encoding_GH_1113
        utf8 = '<frag>shahid ὡ 𐄣 𢂁</frag>'
        hex = '<frag>shahid &#x1f61; &#x10123; &#x22081;</frag>'
        decimal = '<frag>shahid &#8033; &#65827; &#139393;</frag>'
        expected = Nokogiri.jruby? ? hex : decimal

        frag = Nokogiri::XML(utf8, nil, 'UTF-8', Nokogiri::XML::ParseOptions::STRICT)
        assert_equal utf8, frag.to_xml.sub(/^<.xml[^>]*>\n/m, '').strip

        frag = Nokogiri::XML(expected, nil, 'UTF-8', Nokogiri::XML::ParseOptions::STRICT)
        assert_equal utf8, frag.to_xml.sub(/^<.xml[^>]*>\n/m, '').strip

        frag = Nokogiri::XML(expected, nil, 'US-ASCII', Nokogiri::XML::ParseOptions::STRICT)
        assert_equal expected, frag.to_xml.sub(/^<.xml[^>]*>\n/m, '').strip
      end

      VEHICLE_XML = <<-eoxml
        <root>
          <car xmlns:part="http://general-motors.com/">
            <part:tire>Michelin Model XGV</part:tire>
          </car>
          <bicycle xmlns:part="http://schwinn.com/">
            <part:tire>I'm a bicycle tire!</part:tire>
          </bicycle>
        </root>
      eoxml

      def test_namespace
        doc = Nokogiri::XML(VEHICLE_XML.encode('Shift_JIS'), nil, 'Shift_JIS')
        assert_equal 'Shift_JIS', doc.encoding
        n = doc.xpath('//part:tire', { 'part' => 'http://schwinn.com/' }).first
        assert n
        assert_equal 'UTF-8', n.namespace.href.encoding.name
        assert_equal 'UTF-8', n.namespace.prefix.encoding.name
      end

      def test_namespace_as_hash
        doc = Nokogiri::XML(VEHICLE_XML.encode('Shift_JIS'), nil, 'Shift_JIS')
        assert_equal 'Shift_JIS', doc.encoding
        assert n = doc.xpath('//car').first

        n.namespace_definitions.each do |nd|
          assert_equal 'UTF-8', nd.href.encoding.name
          assert_equal 'UTF-8', nd.prefix.encoding.name
        end

        n.namespaces.each do |k,v|
          assert_equal 'UTF-8', k.encoding.name
          assert_equal 'UTF-8', v.encoding.name
        end
      end
    end
  end
end
