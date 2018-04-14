# -*- coding: utf-8 -*-

require "helper"

module Nokogiri
  module XML
    module SAX
      class TestParser < Nokogiri::SAX::TestCase
        def setup
          super
          @parser = XML::SAX::Parser.new(Doc.new)
        end

        def test_parser_context_yielded_io
          doc = Doc.new
          parser = XML::SAX::Parser.new doc
          xml = "<foo a='&amp;b'/>"

          block_called = false
          parser.parse(StringIO.new(xml)) { |ctx|
            block_called = true
            ctx.replace_entities = true
          }

          assert block_called

          assert_equal [['foo', [['a', '&b']]]], doc.start_elements
        end

        def test_parser_context_yielded_in_memory
          doc = Doc.new
          parser = XML::SAX::Parser.new doc
          xml = "<foo a='&amp;b'/>"

          block_called = false
          parser.parse(xml) { |ctx|
            block_called = true
            ctx.replace_entities = true
          }

          assert block_called

          assert_equal [['foo', [['a', '&b']]]], doc.start_elements
        end

        def test_xml_decl
          [
            ['', nil],
            ['<?xml version="1.0" ?>',
              ['1.0']],
            ['<?xml version="1.0" encoding="UTF-8" ?>',
              ['1.0', 'UTF-8']],
            ['<?xml version="1.0" standalone="yes"?>',
              ['1.0', 'yes']],
            ['<?xml version="1.0" standalone="no"?>',
              ['1.0', 'no']],
            ['<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
              ['1.0', "UTF-8", 'no']],
            ['<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>',
              ['1.0', "ISO-8859-1", 'yes']]
          ].each do |decl, value|
            parser = XML::SAX::Parser.new(Doc.new)

            xml = "#{decl}\n<root />"
            parser.parse xml
            assert parser.document.start_document_called, xml
            assert_equal value, parser.document.xmldecls, xml
          end
        end

        def test_parse_empty
          assert_raises RuntimeError do
            @parser.parse('')
          end
        end

        def test_namespace_declaration_order_is_saved
          @parser.parse <<-eoxml
<root xmlns:foo='http://foo.example.com/' xmlns='http://example.com/'>
  <a foo:bar='hello' />
</root>
          eoxml
          assert_equal 2, @parser.document.start_elements_namespace.length
          el = @parser.document.start_elements_namespace.first
          namespaces = el.last
          assert_equal ['foo', 'http://foo.example.com/'], namespaces.first
          assert_equal [nil, 'http://example.com/'], namespaces.last
        end

        def test_bad_document_calls_error_handler
          @parser.parse('<foo><bar></foo>')
          assert @parser.document.errors
          assert @parser.document.errors.length > 0
        end

        def test_namespace_are_super_fun_to_parse
          @parser.parse <<-eoxml
<root xmlns:foo='http://foo.example.com/'>
  <a foo:bar='hello' />
  <b xmlns:foo='http://bar.example.com/'>
    <a foo:bar='hello' />
  </b>
  <foo:bar>hello world</foo:bar>
</root>
          eoxml

          assert @parser.document.start_elements_namespace.length > 0
          el = @parser.document.start_elements_namespace[1]
          assert_equal 'a', el.first
          assert_equal 1, el[1].length

          attribute = el[1].first
          assert_equal 'bar', attribute.localname
          assert_equal 'foo', attribute.prefix
          assert_equal 'hello', attribute.value
          assert_equal 'http://foo.example.com/', attribute.uri
        end

        def test_sax_v1_namespace_attribute_declarations
          @parser.parse <<-eoxml
<root xmlns:foo='http://foo.example.com/' xmlns='http://example.com/'>
  <a foo:bar='hello' />
  <b xmlns:foo='http://bar.example.com/'>
    <a foo:bar='hello' />
  </b>
  <foo:bar>hello world</foo:bar>
</root>
          eoxml
          assert @parser.document.start_elements.length > 0
          elm = @parser.document.start_elements.first
          assert_equal 'root', elm.first
          assert elm[1].include?(['xmlns:foo', 'http://foo.example.com/'])
          assert elm[1].include?(['xmlns', 'http://example.com/'])
        end

        def test_sax_v1_namespace_nodes
          @parser.parse <<-eoxml
<root xmlns:foo='http://foo.example.com/' xmlns='http://example.com/'>
  <a foo:bar='hello' />
  <b xmlns:foo='http://bar.example.com/'>
    <a foo:bar='hello' />
  </b>
  <foo:bar>hello world</foo:bar>
</root>
          eoxml
          assert_equal 5, @parser.document.start_elements.length
          assert @parser.document.start_elements.map(&:first).include?('foo:bar')
          assert @parser.document.end_elements.map(&:first).include?('foo:bar')
        end

        def test_start_is_called_without_namespace
          @parser.parse(<<-eoxml)
<root xmlns:foo='http://foo.example.com/' xmlns='http://example.com/'>
<foo:f><bar></foo:f>
</root>
          eoxml
          assert_equal ['root', 'foo:f', 'bar'],
            @parser.document.start_elements.map(&:first)
        end

        def test_parser_sets_encoding
          parser = XML::SAX::Parser.new(Doc.new, 'UTF-8')
          assert_equal 'UTF-8', parser.encoding
        end

        def test_errors_set_after_parsing_bad_dom
          doc = Nokogiri::XML('<foo><bar></foo>')
          assert doc.errors

          @parser.parse('<foo><bar></foo>')
          assert @parser.document.errors
          assert @parser.document.errors.length > 0

          doc.errors.each do |error|
            assert_equal 'UTF-8', error.message.encoding.name
          end

          # when using JRuby Nokogiri, more errors will be generated as the DOM
          # parser continue to parse an ill formed document, while the sax parser
          # will stop at the first error
          unless Nokogiri.jruby?
            assert_equal doc.errors.length, @parser.document.errors.length
          end
        end

        def test_parse_with_memory_argument
          @parser.parse(File.read(XML_FILE))
          assert(@parser.document.cdata_blocks.length > 0)
        end

        def test_parse_with_io_argument
          File.open(XML_FILE, 'rb') { |f|
            @parser.parse(f)
          }
          assert(@parser.document.cdata_blocks.length > 0)
        end

        def test_parse_io
          call_parse_io_with_encoding 'UTF-8'
        end

        # issue #828
        def test_parse_io_lower_case_encoding
          call_parse_io_with_encoding 'utf-8'
        end

        def call_parse_io_with_encoding encoding
          File.open(XML_FILE, 'rb') { |f|
            @parser.parse_io(f, encoding)
          }
          assert(@parser.document.cdata_blocks.length > 0)

          called = false
          @parser.document.start_elements.flatten.each do |thing|
            assert_equal 'UTF-8', thing.encoding.name
            called = true
          end
          assert called

          called = false
          @parser.document.end_elements.flatten.each do |thing|
            assert_equal 'UTF-8', thing.encoding.name
            called = true
          end
          assert called

          called = false
          @parser.document.data.each do |thing|
            assert_equal 'UTF-8', thing.encoding.name
            called = true
          end
          assert called

          called = false
          @parser.document.comments.flatten.each do |thing|
            assert_equal 'UTF-8', thing.encoding.name
            called = true
          end
          assert called

          called = false
          @parser.document.cdata_blocks.flatten.each do |thing|
            assert_equal 'UTF-8', thing.encoding.name
            called = true
          end
          assert called
        end

        def test_parse_file
          @parser.parse_file(XML_FILE)

          assert_raises(ArgumentError) {
            @parser.parse_file(nil)
          }

          assert_raises(Errno::ENOENT) {
            @parser.parse_file('')
          }
          assert_raises(Errno::EISDIR) {
            @parser.parse_file(File.expand_path(File.dirname(__FILE__)))
          }
        end

        def test_render_parse_nil_param
          assert_raises(ArgumentError) { @parser.parse_memory(nil) }
        end

        def test_bad_encoding_args
          assert_raises(ArgumentError) { XML::SAX::Parser.new(Doc.new, 'not an encoding') }
          assert_raises(ArgumentError) { @parser.parse_io(StringIO.new('<root/>'), 'not an encoding')}
        end

        def test_ctag
          @parser.parse_memory(<<-eoxml)
            <p id="asdfasdf">
              <![CDATA[ This is a comment ]]>
              Paragraph 1
            </p>
          eoxml
          assert_equal [' This is a comment '], @parser.document.cdata_blocks
        end

        def test_comment
          @parser.parse_memory(<<-eoxml)
            <p id="asdfasdf">
              <!-- This is a comment -->
              Paragraph 1
            </p>
          eoxml
          assert_equal [' This is a comment '], @parser.document.comments
        end

        def test_characters
          @parser.parse_memory(<<-eoxml)
            <p id="asdfasdf">Paragraph 1</p>
          eoxml
          assert_equal ['Paragraph 1'], @parser.document.data
        end

        def test_end_document
          @parser.parse_memory(<<-eoxml)
            <p id="asdfasdf">Paragraph 1</p>
          eoxml
          assert @parser.document.end_document_called
        end

        def test_end_element
          @parser.parse_memory(<<-eoxml)
            <p id="asdfasdf">Paragraph 1</p>
          eoxml
          assert_equal [["p"]],
            @parser.document.end_elements
        end

        def test_start_element_attrs
          @parser.parse_memory(<<-eoxml)
            <p id="asdfasdf">Paragraph 1</p>
          eoxml
          assert_equal [["p", [["id", "asdfasdf"]]]],
                       @parser.document.start_elements
        end

        def test_start_element_attrs_include_namespaces
          @parser.parse_memory(<<-eoxml)
            <p xmlns:foo='http://foo.example.com/'>Paragraph 1</p>
          eoxml
          assert_equal [["p", [['xmlns:foo', 'http://foo.example.com/']]]],
                       @parser.document.start_elements
        end

        def test_processing_instruction
          @parser.parse_memory(<<-eoxml)
            <?xml-stylesheet href="a.xsl" type="text/xsl"?>
            <?xml version="1.0"?>
          eoxml
          assert_equal [['xml-stylesheet', 'href="a.xsl" type="text/xsl"']],
                       @parser.document.processing_instructions
        end

        if Nokogiri.uses_libxml? # JRuby SAXParser only parses well-formed XML documents
          def test_parse_document
            @parser.parse_memory(<<-eoxml)
              <p>Paragraph 1</p>
              <p>Paragraph 2</p>
            eoxml
          end
        end

        def test_parser_attributes
          xml = <<-eoxml
<?xml version="1.0" ?><root><foo a="&amp;b" c="&gt;d" /></root>
          eoxml

          block_called = false
          @parser.parse(xml) { |ctx|
            block_called = true
            ctx.replace_entities = true
          }

          assert block_called

          assert_equal [['root', []], ['foo', [['a', '&b'], ['c', '>d']]]], @parser.document.start_elements
        end

        def test_recovery_from_incorrect_xml
          xml = <<-eoxml
<?xml version="1.0" ?><Root><Data><?xml version='1.0'?><Item>hey</Item></Data><Data><Item>hey yourself</Item></Data></Root>
          eoxml

          block_called = false
          @parser.parse(xml) { |ctx|
            block_called = true
            ctx.recovery = true
          }

          assert block_called

          assert_equal [['Root', []], ['Data', []], ['Item', []], ['Data', []], ['Item', []]], @parser.document.start_elements
        end

        def test_square_bracket_in_text  # issue 1261
          xml = <<-eoxml
<tu tuid="87dea04cf60af103ff09d1dba36ae820" segtype="block">
  <prop type="x-smartling-string-variant">en:#:home_page:#:stories:#:[6]:#:name</prop>
  <tuv xml:lang="en-US"><seg>Sandy S.</seg></tuv>
</tu>
          eoxml
          @parser.parse(xml)
          assert @parser.document.data.must_include "en:#:home_page:#:stories:#:[6]:#:name"
        end
      end
    end
  end
end
