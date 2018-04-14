require "helper"

module Nokogiri
  module XML
    class TestEntityReference < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(File.open(XML_FILE), XML_FILE)
      end

      def test_new
        assert ref = EntityReference.new(@xml, 'ent4')
        assert_instance_of EntityReference, ref
      end

      def test_many_references
        100.times { EntityReference.new(@xml, 'foo') }
      end

      def test_newline_node
        # issue 719
        xml = <<EOF
<?xml version="1.0" ?>
<item></item>
EOF
        doc = Nokogiri::XML xml
        lf_node = Nokogiri::XML::EntityReference.new(doc, "#xa")
        doc.xpath('/item').first.add_child(lf_node)
        assert_match(/&#xa;/, doc.to_xml)
      end

      def test_children_should_always_be_empty
        # https://github.com/sparklemotion/nokogiri/issues/1238
        #
        # libxml2 will create a malformed child node for predefined
        # entities. because any use of that child is likely to cause a
        # segfault, we shall pretend that it doesn't exist.
        entity = Nokogiri::XML::EntityReference.new(@xml, "amp")
        assert_equal 0, entity.children.length
        entity.inspect # should not segfault
      end
    end

    module Common
      PATH = 'test/files/test_document_url/'

      attr_accessor :path, :parser

      def xml_document
        File.join path, 'document.xml'
      end

      def self.included base
        def base.test_relative_and_absolute_path method_name, &block
          test_relative_path method_name, &block
          test_absolute_path method_name, &block
        end

        def base.test_absolute_path method_name, &block
          define_method "#{method_name}_with_absolute_path" do
            self.path = "#{File.expand_path PATH}/"
            instance_eval(&block)
          end
        end

        def base.test_relative_path method_name, &block
          define_method method_name do
            self.path = PATH
            instance_eval(&block)
          end
        end
      end
    end

    class TestDOMEntityReference < Nokogiri::TestCase
      include Common

      def setup
        super
        @parser = Nokogiri::XML::Document
      end

      test_relative_and_absolute_path :test_dom_entity_reference_with_dtdloda do
        # Make sure that we can parse entity references and include them in the document
        html = File.read xml_document
        doc = @parser.parse html, path do |cfg|
          cfg.default_xml
          cfg.dtdload
          cfg.noent
        end
        assert_equal [], doc.errors
        assert_equal "foobar", doc.xpath('//blah').text
      end

      test_relative_and_absolute_path :test_dom_entity_reference_with_dtdvalid do
        # Make sure that we can parse entity references and include them in the document
        html = File.read xml_document
        doc = @parser.parse html, path do |cfg|
          cfg.default_xml
          cfg.dtdvalid
          cfg.noent
        end
        assert_equal [], doc.errors
        assert_equal "foobar", doc.xpath('//blah').text
      end

      test_absolute_path :test_dom_dtd_loading_with_absolute_path do
        # Make sure that we can parse entity references and include them in the document
        html = %Q[<?xml version="1.0" encoding="UTF-8" ?>
                  <!DOCTYPE document SYSTEM "#{path}/document.dtd">
                    <document>
                      <body>&bar;</body>
                    </document>
        ]
        doc = @parser.parse html, xml_document do |cfg|
          cfg.default_xml
          cfg.dtdvalid
          cfg.noent
        end
        assert_equal [], doc.errors
        assert_equal "foobar", doc.xpath('//blah').text
      end

      test_relative_and_absolute_path :test_dom_entity_reference_with_io do
        # Make sure that we can parse entity references and include them in the document
        html = File.open xml_document
        doc = @parser.parse html, nil do |cfg|
          cfg.default_xml
          cfg.dtdload
          cfg.noent
        end
        assert_equal [], doc.errors
        assert_equal "foobar", doc.xpath('//blah').text
      end

      test_relative_and_absolute_path :test_dom_entity_reference_without_noent do
        # Make sure that we don't include entity references unless NOENT is set to true
        html = File.read xml_document
        doc = @parser.parse html, path do |cfg|
          cfg.default_xml
          cfg.dtdload
        end
        assert_equal [], doc.errors
        assert_kind_of Nokogiri::XML::EntityReference, doc.xpath('//body').first.children.first
      end

      test_relative_and_absolute_path :test_dom_entity_reference_without_dtdload do
        # Make sure that we don't include entity references unless NOENT is set to true
        html = File.read xml_document
        doc = @parser.parse html, path do |cfg|
          cfg.default_xml
        end
        assert_kind_of Nokogiri::XML::EntityReference, doc.xpath('//body').first.children.first
        if Nokogiri.uses_libxml?
          assert_equal ["5:14: ERROR: Entity 'bar' not defined"], doc.errors.map(&:to_s)
        end
      end

      test_relative_and_absolute_path :test_document_dtd_loading_with_nonet do
        # Make sure that we don't include remote entities unless NOENT is set to true
        html = %Q[<?xml version="1.0" encoding="UTF-8" ?>
                  <!DOCTYPE document SYSTEM "http://foo.bar.com/">
                    <document>
                      <body>&bar;</body>
                    </document>
        ]
        doc = @parser.parse html, path do |cfg|
          cfg.default_xml
          cfg.dtdload
        end
        assert_kind_of Nokogiri::XML::EntityReference, doc.xpath('//body').first.children.first
        if Nokogiri.uses_libxml?
          assert_equal ["ERROR: Attempt to load network entity http://foo.bar.com/", "4:34: ERROR: Entity 'bar' not defined"], doc.errors.map(&:to_s)
        else
          assert_equal ["Attempt to load network entity http://foo.bar.com/"], doc.errors.map(&:to_s)
        end
      end
      # TODO: can we retreive a resource pointing to localhost when NONET is set to true ?
    end

    class TestSaxEntityReference < Nokogiri::SAX::TestCase
      include Common

      def setup
        super
        @parser = XML::SAX::Parser.new(Doc.new) do |ctx|
          ctx.replace_entities = true
        end
      end

      test_relative_and_absolute_path :test_sax_entity_reference do
        # Make sure that we can parse entity references and include them in the document
        html = File.read xml_document
        @parser.parse html
        refute_nil @parser.document.errors
        assert_equal ["Entity 'bar' not defined"], @parser.document.errors.map(&:to_s).map(&:strip)
      end

      test_relative_and_absolute_path :test_more_sax_entity_reference do
        # Make sure that we don't include entity references unless NOENT is set to true
        html = %Q[<?xml version="1.0" encoding="UTF-8" ?>
                  <!DOCTYPE document SYSTEM "http://foo.bar.com/">
                    <document>
                      <body>&bar;</body>
                    </document>
        ]
        @parser.parse html
        refute_nil @parser.document.errors
        assert_equal ["Entity 'bar' not defined"], @parser.document.errors.map(&:to_s).map(&:strip)
      end
    end

    class TestReaderEntityReference < Nokogiri::TestCase
      include Common

      def setup
        super
      end

      test_relative_and_absolute_path :test_reader_entity_reference do
        # Make sure that we can parse entity references and include them in the document
        html = File.read xml_document
        reader = Nokogiri::XML::Reader html, path do |cfg|
          cfg.default_xml
          cfg.dtdload
          cfg.noent
        end
        nodes = []
        reader.each { |n| nodes << n.value }
        assert_equal ['foobar'], nodes.compact.map(&:strip).reject(&:empty?)
      end

      test_relative_and_absolute_path :test_reader_entity_reference_without_noent do
        # Make sure that we can parse entity references and include them in the document
        html = File.read xml_document
        reader = Nokogiri::XML::Reader html, path do |cfg|
          cfg.default_xml
          cfg.dtdload
        end
        nodes = []
        reader.each { |n| nodes << n.value }
        assert_equal [], nodes.compact.map(&:strip).reject(&:empty?)
      end

      test_relative_and_absolute_path :test_reader_entity_reference_without_dtdload do
        html = File.read xml_document
        reader = Nokogiri::XML::Reader html, path do |cfg|
          cfg.default_xml
        end
        if Nokogiri.uses_libxml? && Nokogiri::LIBXML_PARSER_VERSION.to_i >= 20900
          # Unknown entity is not fatal in libxml2 >= 2.9
          assert_equal 8, reader.count
        else
          assert_raises(Nokogiri::XML::SyntaxError) {
            assert_equal 5, reader.count
          }
        end
        assert_operator reader.errors.size, :>, 0
      end
    end
  end
end
