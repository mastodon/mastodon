require "helper"

module Nokogiri
  module XML
    class TestSchema < Nokogiri::TestCase
      def setup
        assert @xsd = Nokogiri::XML::Schema(File.read(PO_SCHEMA_FILE))
      end

      def test_schema_from_document
        doc = Nokogiri::XML(File.open(PO_SCHEMA_FILE))
        assert doc
        xsd = Nokogiri::XML::Schema.from_document doc
        assert_instance_of Nokogiri::XML::Schema, xsd
      end

      def test_invalid_schema_do_not_raise_exceptions
        xsd = Nokogiri::XML::Schema.new <<EOF
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:group name="foo1">
		<xs:sequence>
			<xs:element name="bar" type="xs:boolean" />
		</xs:sequence>
  </xs:group>
	<xs:group name="foo2">
		<xs:sequence>
			<xs:element name="bar" type="xs:string" />
		</xs:sequence>
  </xs:group>
	<xs:element name="foo">
		<xs:complexType>
			<xs:choice>
				<xs:group ref="foo1"/>
				<xs:group ref="foo2"/>
			</xs:choice>
		</xs:complexType>
	</xs:element>
</xs:schema>
EOF
        assert_instance_of Nokogiri::XML::Schema, xsd
      end

      def test_schema_from_document_node
        doc = Nokogiri::XML(File.open(PO_SCHEMA_FILE))
        assert doc
        xsd = Nokogiri::XML::Schema.from_document doc.root
        assert_instance_of Nokogiri::XML::Schema, xsd
      end

      def test_schema_validates_with_relative_paths
        xsd = File.join(ASSETS_DIR, 'foo', 'foo.xsd')
        xml = File.join(ASSETS_DIR, 'valid_bar.xml')
        doc = Nokogiri::XML(File.open(xsd))
        xsd = Nokogiri::XML::Schema.from_document doc

        doc = Nokogiri::XML(File.open(xml))
        assert xsd.valid?(doc)
      end

      def test_parse_with_memory
        assert_instance_of Nokogiri::XML::Schema, @xsd
        assert_equal 0, @xsd.errors.length
      end

      def test_new
        assert xsd = Nokogiri::XML::Schema.new(File.read(PO_SCHEMA_FILE))
        assert_instance_of Nokogiri::XML::Schema, xsd
      end

      def test_parse_with_io
        xsd = nil
        File.open(PO_SCHEMA_FILE, 'rb') { |f|
          assert xsd = Nokogiri::XML::Schema(f)
        }
        assert_equal 0, xsd.errors.length
      end

      def test_parse_with_errors
        xml = File.read(PO_SCHEMA_FILE).sub(/name="/, 'name=')
        assert_raises(Nokogiri::XML::SyntaxError) {
          Nokogiri::XML::Schema(xml)
        }
      end

      def test_validate_document
        doc = Nokogiri::XML(File.read(PO_XML_FILE))
        assert errors = @xsd.validate(doc)
        assert_equal 0, errors.length
      end

      def test_validate_file
        assert errors = @xsd.validate(PO_XML_FILE)
        assert_equal 0, errors.length
      end

      def test_validate_invalid_document
        doc = Nokogiri::XML File.read(PO_XML_FILE)
        doc.css("city").unlink

        assert errors = @xsd.validate(doc)
        assert_equal 2, errors.length
      end

      def test_validate_invalid_file
        tempfile = Tempfile.new("xml")

        doc = Nokogiri::XML File.read(PO_XML_FILE)
        doc.css("city").unlink
        tempfile.write doc.to_xml
        tempfile.close

        assert errors = @xsd.validate(tempfile.path)
        assert_equal 2, errors.length
      end

      def test_validate_non_document
        string = File.read(PO_XML_FILE)
        assert_raise(ArgumentError) {@xsd.validate(string)}
      end

      def test_valid?
        valid_doc = Nokogiri::XML(File.read(PO_XML_FILE))

        invalid_doc = Nokogiri::XML(
          File.read(PO_XML_FILE).gsub(/<city>[^<]*<\/city>/, '')
        )

        assert(@xsd.valid?(valid_doc))
        assert(!@xsd.valid?(invalid_doc))
      end

      def test_xsd_with_dtd
        Dir.chdir(File.join(ASSETS_DIR, 'saml')) do
           # works
           Nokogiri::XML::Schema(IO.read('xmldsig_schema.xsd'))
           # was not working
           Nokogiri::XML::Schema(IO.read('saml20protocol_schema.xsd'))
        end
      end
    end
  end
end
