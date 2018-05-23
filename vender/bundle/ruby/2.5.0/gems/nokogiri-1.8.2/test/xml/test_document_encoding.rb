require "helper"

module Nokogiri
  module XML
    class TestDocumentEncoding < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(File.read(SHIFT_JIS_XML), SHIFT_JIS_XML)
      end

      def test_url
        assert_equal 'UTF-8', @xml.url.encoding.name
      end

      def test_encoding
        assert_equal 'UTF-8', @xml.encoding.encoding.name
      end

      def test_dotted_version
        if Nokogiri.uses_libxml?
          assert_equal 'UTF-8', Nokogiri::LIBXML_VERSION.encoding.name
        end
      end

      def test_empty_doc_encoding
        encoding = 'US-ASCII'
        assert_equal encoding, Nokogiri::XML(nil, nil, encoding).encoding
      end
    end
  end
end
