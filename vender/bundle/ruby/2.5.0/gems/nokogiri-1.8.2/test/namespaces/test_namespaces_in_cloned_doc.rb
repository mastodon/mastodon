require "helper"

module Nokogiri
  module XML
    class TestNamespacesInClonedDoc < Nokogiri::TestCase
      def setup
        super
        b = Nokogiri::XML::Builder.new do |xml|
          xml.mods("xmlns"=>"http://www.loc.gov/mods/v3") {
            xml.name(:type=>"personal") {
              xml.namePart()
            }
          }
        end

        @doc = b.doc
        @clone = Nokogiri::XML(@doc.to_s)
      end

      def check_namespace e
        e.namespace.nil? ? nil : e.namespace.href
      end

      def test_namespace_ns
        xpath = '//oxns:name[@type="personal"]'
        namespaces = {'oxns' => "http://www.loc.gov/mods/v3"}
        assert_equal @doc.xpath(xpath, namespaces).length, @clone.xpath(xpath, namespaces).length
      end
    end
  end
end