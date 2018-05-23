require "helper"

require 'uri'

module Nokogiri
  module XML
    class TestDocument < Nokogiri::TestCase
      URI = if URI.const_defined?(:DEFAULT_PARSER)
              ::URI::DEFAULT_PARSER
            else
              ::URI
            end

      def setup
        super
        @xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
      end

      def test_dtd_with_empty_internal_subset
        doc = Nokogiri::XML <<-eoxml
<?xml version="1.0"?>
<!DOCTYPE people >
<people>
</people>
        eoxml
        assert doc.root
      end

      # issue #1005
      def test_strict_parsing_empty_doc_should_raise_exception
        ["", " "].each do |empty_string|
          assert_raises(SyntaxError, "empty string '#{empty_string}' should raise a SyntaxError") do
            Nokogiri::XML(empty_string) { |c| c.strict }
          end
          assert_raises(SyntaxError, "StringIO of '#{empty_string}' should raise a SyntaxError") do
            Nokogiri::XML(StringIO.new(empty_string)) { |c| c.strict }
          end
        end
      end

      # issue #838
      def test_document_with_invalid_prolog
        doc = Nokogiri::XML '<? ?>'
        assert_empty doc.content
      end

      # issue #837
      def test_document_with_refentity
        doc = Nokogiri::XML '&amp;'
        assert_equal '', doc.content
      end

      # issue #835
      def test_manually_adding_reference_entities
        d = Nokogiri::XML::Document.new
        root = Nokogiri::XML::Element.new('bar', d)
        txt = Nokogiri::XML::Text.new('foo', d)
        ent = Nokogiri::XML::EntityReference.new(d, '#8217')
        root << txt
        root << ent
        d << root
        assert_match(/&#8217;/, d.to_html)
      end

      def test_document_with_initial_space
        doc = Nokogiri::XML(" <?xml version='1.0' encoding='utf-8' ?><first \>")
        assert_equal 2, doc.children.size
      end

      def test_root_set_to_nil
        @xml.root = nil
        assert_equal nil, @xml.root
      end

      def test_million_laugh_attach
        doc = Nokogiri::XML '<?xml version="1.0"?>
<!DOCTYPE lolz [
<!ENTITY lol "lol">
<!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
<!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
<!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
<!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
<!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
<!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
<!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
<!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<lolz>&lol9;</lolz>'
        assert_not_nil doc
      end

      def test_million_laugh_attach_2
        doc = Nokogiri::XML '<?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE member [
   <!ENTITY a "&b;&b;&b;&b;&b;&b;&b;&b;&b;&b;">
   <!ENTITY b "&c;&c;&c;&c;&c;&c;&c;&c;&c;&c;">
   <!ENTITY c "&d;&d;&d;&d;&d;&d;&d;&d;&d;&d;">
   <!ENTITY d "&e;&e;&e;&e;&e;&e;&e;&e;&e;&e;">
   <!ENTITY e "&f;&f;&f;&f;&f;&f;&f;&f;&f;&f;">
   <!ENTITY f "&g;&g;&g;&g;&g;&g;&g;&g;&g;&g;">
   <!ENTITY g "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx">
 ]>
 <member>
 &a;
 </member>'
        assert_not_nil doc
      end

      def test_ignore_unknown_namespace
        doc = Nokogiri::XML(<<-eoxml)
        <xml>
          <unknown:foo xmlns='http://hello.com/' />
          <bar />
        </xml>
        eoxml
        if Nokogiri.jruby?
          refute doc.xpath('//foo').first.namespace # assert that the namespace is nil
        end
        refute_empty doc.xpath('//bar'), "bar wasn't found in the document" # bar should be part of the doc
      end

      def test_collect_namespaces
        doc = Nokogiri::XML(<<-eoxml)
        <xml>
          <foo xmlns='hello'>
            <bar xmlns:foo='world' />
          </foo>
        </xml>
        eoxml
        assert_equal({"xmlns"=>"hello", "xmlns:foo"=>"world"},
          doc.collect_namespaces)
      end

      def test_subclass_initialize_modify # testing a segv
        Class.new(Nokogiri::XML::Document) {
          def initialize
            super
            body_node = Nokogiri::XML::Node.new "body", self
            body_node.content = "stuff"
            self.root = body_node
          end
        }.new
      end

      def test_create_text_node
        txt = @xml.create_text_node 'foo'
        assert_instance_of Nokogiri::XML::Text, txt
        assert_equal 'foo', txt.text
        assert_equal @xml, txt.document
      end

      def test_create_text_node_with_block
        @xml.create_text_node 'foo' do |txt|
          assert_instance_of Nokogiri::XML::Text, txt
          assert_equal 'foo', txt.text
          assert_equal @xml, txt.document
        end
      end

      def test_create_element
        elm = @xml.create_element('foo')
        assert_instance_of Nokogiri::XML::Element, elm
        assert_equal 'foo', elm.name
        assert_equal @xml, elm.document
      end

      def test_create_element_with_block
        @xml.create_element('foo') do |elm|
          assert_instance_of Nokogiri::XML::Element, elm
          assert_equal 'foo', elm.name
          assert_equal @xml, elm.document
        end
      end

      def test_create_element_with_attributes
        elm = @xml.create_element('foo',:a => "1")
        assert_instance_of Nokogiri::XML::Element, elm
        assert_instance_of Nokogiri::XML::Attr, elm.attributes["a"]
        assert_equal "1", elm["a"]
      end

      def test_create_element_with_namespace
        elm = @xml.create_element('foo',:'xmlns:foo' => 'http://tenderlovemaking.com')
        assert_equal 'http://tenderlovemaking.com', elm.namespaces['xmlns:foo']
      end

      def test_create_element_with_hyphenated_namespace
        elm = @xml.create_element('foo',:'xmlns:SOAP-ENC' => 'http://tenderlovemaking.com')
        assert_equal 'http://tenderlovemaking.com', elm.namespaces['xmlns:SOAP-ENC']
      end

      def test_create_element_with_content
        elm = @xml.create_element('foo',"needs more xml/violence")
        assert_equal "needs more xml/violence", elm.content
      end

      def test_create_cdata
        cdata = @xml.create_cdata("abc")
        assert_instance_of Nokogiri::XML::CDATA, cdata
        assert_equal "abc", cdata.content
      end

      def test_create_cdata_with_block
        @xml.create_cdata("abc") do |cdata|
          assert_instance_of Nokogiri::XML::CDATA, cdata
          assert_equal "abc", cdata.content
        end
      end

      def test_create_comment
        comment = @xml.create_comment("abc")
        assert_instance_of Nokogiri::XML::Comment, comment
        assert_equal "abc", comment.content
      end

      def test_create_comment_with_block
        @xml.create_comment("abc") do |comment|
          assert_instance_of Nokogiri::XML::Comment, comment
          assert_equal "abc", comment.content
        end
      end

      def test_pp
        out = StringIO.new(String.new)
        ::PP.pp @xml, out
        assert_operator out.string.length, :>, 0
      end

      def test_create_internal_subset_on_existing_subset
        assert_not_nil @xml.internal_subset
        assert_raises(RuntimeError) do
          @xml.create_internal_subset('staff', nil, 'staff.dtd')
        end
      end

      def test_create_internal_subset
        xml = Nokogiri::XML('<root />')
        assert_nil xml.internal_subset

        xml.create_internal_subset('name', nil, 'staff.dtd')
        ss = xml.internal_subset
        assert_equal 'name', ss.name
        assert_nil ss.external_id
        assert_equal 'staff.dtd', ss.system_id
      end

      def test_external_subset
        assert_nil @xml.external_subset
        Dir.chdir(ASSETS_DIR) do
          @xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE) { |cfg|
            cfg.dtdload
          }
        end
        assert @xml.external_subset
      end

      def test_create_external_subset_fails_with_existing_subset
        assert_nil @xml.external_subset
        Dir.chdir(ASSETS_DIR) do
          @xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE) { |cfg|
            cfg.dtdload
          }
        end
        assert @xml.external_subset

        assert_raises(RuntimeError) do
          @xml.create_external_subset('staff', nil, 'staff.dtd')
        end
      end

      def test_create_external_subset
        dtd = @xml.create_external_subset('staff', nil, 'staff.dtd')
        assert_nil dtd.external_id
        assert_equal 'staff.dtd', dtd.system_id
        assert_equal 'staff', dtd.name
        assert_equal dtd, @xml.external_subset
      end

      def test_version
        assert_equal '1.0', @xml.version
      end

      def test_add_namespace
        assert_raise NoMethodError do
          @xml.add_namespace('foo', 'bar')
        end
      end

      def test_attributes
        assert_raise NoMethodError do
          @xml.attributes
        end
      end

      def test_namespace
        assert_raise NoMethodError do
          @xml.namespace
        end
      end

      def test_namespace_definitions
        assert_raise NoMethodError do
          @xml.namespace_definitions
        end
      end

      def test_line
        assert_raise NoMethodError do
          @xml.line
        end
      end

      def test_empty_node_converted_to_html_is_not_self_closing
        doc = Nokogiri::XML('<a></a>')
        assert_equal "<a></a>", doc.inner_html
      end

      def test_fragment
        fragment = @xml.fragment
        assert_equal 0, fragment.children.length
      end

      def test_add_child_fragment_with_single_node
        doc = Nokogiri::XML::Document.new
        fragment = doc.fragment('<hello />')
        doc.add_child fragment
        assert_equal '/hello', doc.at('//hello').path
        assert_equal 'hello', doc.root.name
      end

      def test_add_child_fragment_with_multiple_nodes
        doc = Nokogiri::XML::Document.new
        fragment = doc.fragment('<hello /><goodbye />')
        assert_raises(RuntimeError) do
          doc.add_child fragment
        end
      end

      def test_add_child_with_multiple_roots
        assert_raises(RuntimeError) do
          @xml << Node.new('foo', @xml)
        end
      end

      def test_add_child_with_string
        doc = Nokogiri::XML::Document.new
        doc.add_child "<div>quack!</div>"
        assert_equal 1, doc.root.children.length
        assert_equal "quack!", doc.root.children.first.content
      end

      def test_prepend
        doc = Nokogiri::XML('<root>')

        node_set = doc.root.prepend_child '<branch/>'
        assert_equal %w[branch], node_set.map(&:name)

        branch = doc.at('//branch')

        leaves = %w[leaf1 leaf2 leaf3]
        leaves.each { |name|
          branch.prepend_child('<%s/>' % name)
        }
        assert_equal leaves.length, branch.children.length
        assert_equal leaves.reverse, branch.children.map(&:name)
      end

      def test_prepend_child_fragment_with_single_node
        doc = Nokogiri::XML::Document.new
        fragment = doc.fragment('<hello />')
        doc.prepend_child fragment
        assert_equal '/hello', doc.at('//hello').path
        assert_equal 'hello', doc.root.name
      end

      def test_prepend_child_fragment_with_multiple_nodes
        doc = Nokogiri::XML::Document.new
        fragment = doc.fragment('<hello /><goodbye />')
        assert_raises(RuntimeError) do
          doc.prepend_child fragment
        end
      end

      def test_prepend_child_with_multiple_roots
        assert_raises(RuntimeError) do
          @xml.prepend_child Node.new('foo', @xml)
        end
      end

      def test_prepend_child_with_string
        doc = Nokogiri::XML::Document.new
        doc.prepend_child "<div>quack!</div>"
        assert_equal 1, doc.root.children.length
        assert_equal "quack!", doc.root.children.first.content
      end

      def test_move_root_to_document_with_no_root
        sender = Nokogiri::XML('<root>foo</root>')
        newdoc = Nokogiri::XML::Document.new
        newdoc.root = sender.root
      end

      def test_move_root_with_existing_root_gets_gcd
        doc = Nokogiri::XML('<root>test</root>')
        doc2 = Nokogiri::XML("<root>#{'x' * 5000000}</root>")
        doc2.root = doc.root
      end

      def test_validate
        if Nokogiri.uses_libxml?
          assert_equal 44, @xml.validate.length
        else
          xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE) {|cfg| cfg.dtdvalid}
          assert_equal 40, xml.validate.length
        end
      end

      def test_validate_no_internal_subset
        doc = Nokogiri::XML('<test/>')
        assert_nil doc.validate
      end

      def test_clone
        assert @xml.clone
      end

      def test_document_should_not_have_default_ns
        doc = Nokogiri::XML::Document.new

        assert_raises NoMethodError do
          doc.default_namespace = 'http://innernet.com/'
        end

        assert_raises NoMethodError do
          doc.add_namespace_definition('foo', 'bar')
        end
      end

      def test_parse_handles_nil_gracefully
        @doc = Nokogiri::XML::Document.parse(nil)
        assert_instance_of Nokogiri::XML::Document, @doc
      end

      def test_parse_takes_block
        options = nil
        Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE) do |cfg|
          options = cfg
        end
        assert options
      end

      def test_parse_yields_parse_options
        options = nil
        Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE) do |cfg|
          options = cfg
          options.nonet.nowarning.dtdattr
        end
        assert options.nonet?
        assert options.nowarning?
        assert options.dtdattr?
      end

      def test_XML_takes_block
        options = nil
        Nokogiri::XML(File.read(XML_FILE), XML_FILE) do |cfg|
          options = cfg
          options.nonet.nowarning.dtdattr
        end
        assert options.nonet?
        assert options.nowarning?
        assert options.dtdattr?
      end

      def test_subclass
        klass = Class.new(Nokogiri::XML::Document)
        doc = klass.new
        assert_instance_of klass, doc
      end

      def test_subclass_initialize
        klass = Class.new(Nokogiri::XML::Document) do
          attr_accessor :initialized_with

          def initialize(*args)
            @initialized_with = args
          end
        end
        doc = klass.new("1.0", 1)
        assert_equal ["1.0", 1], doc.initialized_with
      end

      def test_subclass_dup
        klass = Class.new(Nokogiri::XML::Document)
        doc = klass.new.dup
        assert_instance_of klass, doc
      end

      def test_subclass_parse
        klass = Class.new(Nokogiri::XML::Document)
        doc = klass.parse(File.read(XML_FILE))
        # lame hack uses root to avoid comparing DOCTYPE tags which can appear out of order.
        # I should really finish lorax and use that here.
        assert_equal @xml.root.to_s, doc.root.to_s
        assert_instance_of klass, doc
      end

      def test_document_parse_method
        xml = Nokogiri::XML::Document.parse(File.read(XML_FILE))
        # lame hack uses root to avoid comparing DOCTYPE tags which can appear out of order.
        # I should really finish lorax and use that here.
        assert_equal @xml.root.to_s, xml.root.to_s
      end

      def test_encoding=
        @xml.encoding = 'UTF-8'
        assert_match 'UTF-8', @xml.to_xml

        @xml.encoding = 'EUC-JP'
        assert_match 'EUC-JP', @xml.to_xml
      end

      def test_namespace_should_not_exist
        assert_raises(NoMethodError) {
          @xml.namespace
        }
      end

      def test_non_existant_function
        # WTF.  I don't know why this is different between MRI and Jruby
        # They should be the same...  Either way, raising an exception
        # is the correct thing to do.
        exception = RuntimeError

        if !Nokogiri.uses_libxml? || (Nokogiri.uses_libxml? && Nokogiri::VERSION_INFO['libxml']['platform'] == 'jruby')
          exception = Nokogiri::XML::XPath::SyntaxError
        end

        assert_raises(exception) {
          @xml.xpath('//name[foo()]')
        }
      end

      def test_xpath_syntax_error
        assert_raises(Nokogiri::XML::XPath::SyntaxError) do
          @xml.xpath('\\')
        end
      end

      def test_ancestors
        assert_equal 0, @xml.ancestors.length
      end

      def test_root_node_parent_is_document
        parent = @xml.root.parent
        assert_equal @xml, parent
        assert_instance_of Nokogiri::XML::Document, parent
      end

      def test_xmlns_is_automatically_registered
        doc = Nokogiri::XML(<<-eoxml)
          <root xmlns="http://tenderlovemaking.com/">
            <foo>
              bar
            </foo>
          </root>
        eoxml
        assert_equal 1, doc.css('xmlns|foo').length
        assert_equal 1, doc.css('foo').length
        assert_equal 0, doc.css('|foo').length
        assert_equal 1, doc.xpath('//xmlns:foo').length
        assert_equal 1, doc.search('xmlns|foo').length
        assert_equal 1, doc.search('//xmlns:foo').length
        assert doc.at('xmlns|foo')
        assert doc.at('//xmlns:foo')
        assert doc.at('foo')
      end

      def test_xmlns_is_registered_for_nodesets
        doc = Nokogiri::XML(<<-eoxml)
          <root xmlns="http://tenderlovemaking.com/">
            <foo>
              <bar>
                baz
              </bar>
            </foo>
          </root>
        eoxml
        assert_equal 1, doc.css('xmlns|foo').css('xmlns|bar').length
        assert_equal 1, doc.css('foo').css('bar').length
        assert_equal 1, doc.xpath('//xmlns:foo').xpath('./xmlns:bar').length
        assert_equal 1, doc.search('xmlns|foo').search('xmlns|bar').length
        assert_equal 1, doc.search('//xmlns:foo').search('./xmlns:bar').length
      end

      def test_to_xml_with_indent
        doc = Nokogiri::XML('<root><foo><bar/></foo></root>')
        doc = Nokogiri::XML(doc.to_xml(:indent => 5))

        assert_indent 5, doc
      end

      def test_write_xml_to_with_indent
        io = StringIO.new
        doc = Nokogiri::XML('<root><foo><bar/></foo></root>')
        doc.write_xml_to io, :indent => 5
        io.rewind
        doc = Nokogiri::XML(io.read)
        assert_indent 5, doc
      end

      # wtf...  osx's libxml sucks.
      unless !Nokogiri.uses_libxml? || Nokogiri::LIBXML_VERSION =~ /^2\.6\./
        def test_encoding
          xml = Nokogiri::XML(File.read(XML_FILE), XML_FILE, 'UTF-8')
          assert_equal 'UTF-8', xml.encoding
        end
      end

      def test_memory_explosion_on_invalid_xml
        doc = Nokogiri::XML("<<<")
        refute_nil doc
        refute_empty doc.errors
      end

      def test_memory_explosion_on_wrong_formatted_element_following_the_root_element
        doc = Nokogiri::XML("<a/><\n")
        refute_nil doc
        refute_empty doc.errors
      end

      def test_document_has_errors
        doc = Nokogiri::XML(<<-eoxml)
          <foo><bar></foo>
        eoxml
        assert doc.errors.length > 0
        doc.errors.each do |error|
          assert_match error.message, error.inspect
          assert_match error.message, error.to_s
        end
      end

      def test_strict_document_throws_syntax_error
        assert_raises(Nokogiri::XML::SyntaxError) {
          Nokogiri::XML('<foo><bar></foo>', nil, nil, 0)
        }

        assert_raises(Nokogiri::XML::SyntaxError) {
          Nokogiri::XML('<foo><bar></foo>') { |cfg|
            cfg.strict
          }
        }

        assert_raises(Nokogiri::XML::SyntaxError) {
          Nokogiri::XML(StringIO.new('<foo><bar></foo>')) { |cfg|
            cfg.strict
          }
        }
      end

      def test_XML_function
        xml = Nokogiri::XML(File.read(XML_FILE), XML_FILE)
        assert xml.xml?
      end

      def test_url
        assert @xml.url
        assert_equal XML_FILE, URI.unescape(@xml.url).sub('file:///', '')
      end

      def test_document_parent
        xml = Nokogiri::XML(File.read(XML_FILE), XML_FILE)
        assert_raises(NoMethodError) {
          xml.parent
        }
      end

      def test_document_name
        xml = Nokogiri::XML(File.read(XML_FILE), XML_FILE)
        assert_equal 'document', xml.name
      end

      def test_parse_can_take_io
        xml = nil
        File.open(XML_FILE, 'rb') { |f|
          xml = Nokogiri::XML(f)
        }
        assert xml.xml?
        set = xml.search('//employee')
        assert set.length > 0
      end

      def test_parsing_empty_io
        doc = Nokogiri::XML.parse(StringIO.new(''))
        refute_nil doc
      end

      def test_parse_works_with_an_object_that_responds_to_read
        klass = Class.new do
          def read *args
            "<div>foo</div>"
          end
        end

        doc = Nokogiri::XML.parse klass.new
        doc.at_css("div").content.must_equal("foo")
      end

      def test_search_on_empty_documents
        doc = Nokogiri::XML::Document.new
        ns = doc.search('//foo')
        assert_equal 0, ns.length

        ns = doc.css('foo')
        assert_equal 0, ns.length

        ns = doc.xpath('//foo')
        assert_equal 0, ns.length
      end

      def test_document_search_with_multiple_queries
        xml = '<document>
                 <thing>
                   <div class="title">important thing</div>
                 </thing>
                 <thing>
                   <div class="content">stuff</div>
                 </thing>
                 <thing>
                   <p class="blah">more stuff</div>
                 </thing>
               </document>'
        document = Nokogiri::XML(xml)
        assert_kind_of Nokogiri::XML::Document, document

        assert_equal 3, document.xpath('.//div', './/p').length
        assert_equal 3, document.css('.title', '.content', 'p').length
        assert_equal 3, document.search('.//div', 'p.blah').length
      end

      def test_bad_xpath_raises_syntax_error
        assert_raises(XML::XPath::SyntaxError) {
          @xml.xpath('\\')
        }
      end

      def test_find_with_namespace
        doc = Nokogiri::XML.parse(<<-eoxml)
        <x xmlns:tenderlove='http://tenderlovemaking.com/'>
          <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
        </x>
        eoxml

        ctx = Nokogiri::XML::XPathContext.new(doc)
        ctx.register_ns 'tenderlove', 'http://tenderlovemaking.com/'
        set = ctx.evaluate('//tenderlove:foo')
        assert_equal 1, set.length
        assert_equal 'foo', set.first.name

        # It looks like only the URI is important:
        ctx = Nokogiri::XML::XPathContext.new(doc)
        ctx.register_ns 'america', 'http://tenderlovemaking.com/'
        set = ctx.evaluate('//america:foo')
        assert_equal 1, set.length
        assert_equal 'foo', set.first.name

        # Its so important that a missing slash will cause it to return nothing
        ctx = Nokogiri::XML::XPathContext.new(doc)
        ctx.register_ns 'america', 'http://tenderlovemaking.com'
        set = ctx.evaluate('//america:foo')
        assert_equal 0, set.length
      end

      def test_xml?
        assert @xml.xml?
      end

      def test_document
        assert @xml.document
      end

      def test_singleton_methods
        assert node_set = @xml.search('//name')
        assert node_set.length > 0
        node = node_set.first
        def node.test
          'test'
        end
        assert node_set = @xml.search('//name')
        assert_equal 'test', node_set.first.test
      end

      def test_multiple_search
        assert node_set = @xml.search('//employee', '//name')
        employees = @xml.search('//employee')
        names = @xml.search('//name')
        assert_equal(employees.length + names.length, node_set.length)
      end

      def test_node_set_index
        assert node_set = @xml.search('//employee')

        assert_equal(5, node_set.length)
        assert node_set[4]
        assert_nil node_set[5]
      end

      def test_search
        assert node_set = @xml.search('//employee')

        assert_equal(5, node_set.length)

        node_set.each do |node|
          assert_equal('employee', node.name)
        end
      end

      def test_dump
        assert @xml.serialize
        assert @xml.to_xml
      end

      def test_dup
        dup = @xml.dup
        assert_instance_of Nokogiri::XML::Document, dup
        assert dup.xml?, 'duplicate should be xml'
      end

      def test_new
        doc = nil
        doc = Nokogiri::XML::Document.new
        assert doc
        assert doc.xml?
        assert_nil doc.root
      end

      def test_set_root
        doc = nil
        doc = Nokogiri::XML::Document.new
        assert doc
        assert doc.xml?
        assert_nil doc.root
        node = Nokogiri::XML::Node.new("b", doc) { |n|
          n.content = 'hello world'
        }
        assert_equal('hello world', node.content)
        doc.root = node
        assert_equal(node, doc.root)
      end

      def test_remove_namespaces
        doc = Nokogiri::XML <<-EOX
          <root xmlns:a="http://a.flavorjon.es/" xmlns:b="http://b.flavorjon.es/">
            <a:foo>hello from a</a:foo>
            <b:foo>hello from b</b:foo>
            <container xmlns:c="http://c.flavorjon.es/">
              <c:foo c:attr='attr-value'>hello from c</c:foo>
            </container>
          </root>
        EOX

        namespaces = doc.root.namespaces

        # assert on setup
        assert_equal 2, doc.root.namespaces.length
        assert_equal 3, doc.at_xpath("//container").namespaces.length
        assert_equal 0, doc.xpath("//foo").length
        assert_equal 1, doc.xpath("//a:foo").length
        assert_equal 1, doc.xpath("//a:foo").length
        assert_equal 1, doc.xpath("//x:foo", "x" => "http://c.flavorjon.es/").length
        assert_match %r{foo c:attr}, doc.to_xml
        doc.at_xpath("//x:foo", "x" => "http://c.flavorjon.es/").tap do |node|
          assert_equal nil,          node["attr"]
          assert_equal "attr-value", node["c:attr"]
          assert_equal nil,          node.attribute_with_ns("attr", nil)
          assert_equal "attr-value", node.attribute_with_ns("attr", "http://c.flavorjon.es/").value
          assert_equal "attr-value", node.attributes["attr"].value
        end

        doc.remove_namespaces!

        assert_equal 0, doc.root.namespaces.length
        assert_equal 0, doc.at_xpath("//container").namespaces.length
        assert_equal 3, doc.xpath("//foo").length
        assert_equal 0, doc.xpath("//a:foo", namespaces).length
        assert_equal 0, doc.xpath("//a:foo", namespaces).length
        assert_equal 0, doc.xpath("//x:foo", "x" => "http://c.flavorjon.es/").length
        assert_match %r{foo attr}, doc.to_xml
        doc.at_xpath("//container/foo").tap do |node|
          assert_equal "attr-value", node["attr"]
          assert_equal nil,          node["c:attr"]
          assert_equal "attr-value", node.attribute_with_ns("attr", nil).value
          assert_equal nil,          node.attribute_with_ns("attr", "http://c.flavorjon.es/")
          assert_equal "attr-value", node.attributes["attr"].value # doesn't change!
        end
      end

      # issue #785
      def test_attribute_decoration
        decorator = Module.new do
          def test_method
          end
        end

        util_decorate(@xml, decorator)

        assert @xml.search('//@street').first.respond_to?(:test_method)
      end

      def test_subset_is_decorated
        x = Module.new do
          def awesome!
          end
        end
        util_decorate(@xml, x)

        assert @xml.respond_to?(:awesome!)
        assert node_set = @xml.search('//staff')
        assert node_set.respond_to?(:awesome!)
        assert subset = node_set.search('.//employee')
        assert subset.respond_to?(:awesome!)
        assert sub_subset = node_set.search('.//name')
        assert sub_subset.respond_to?(:awesome!)
      end

      def test_decorator_is_applied
        x = Module.new do
          def awesome!
          end
        end
        util_decorate(@xml, x)

        assert @xml.respond_to?(:awesome!)
        assert node_set = @xml.search('//employee')
        assert node_set.respond_to?(:awesome!)
        node_set.each do |node|
          assert node.respond_to?(:awesome!), node.class
        end
        assert @xml.root.respond_to?(:awesome!)
        assert @xml.children.respond_to?(:awesome!)
      end

      if Nokogiri.jruby?
        def wrap_java_document
          require 'java'
          factory = javax.xml.parsers.DocumentBuilderFactory.newInstance
          builder = factory.newDocumentBuilder
          document = builder.newDocument
          root = document.createElement("foo")
          document.appendChild(root)
          Nokogiri::XML::Document.wrap(document)
        end
      end

      def test_java_integration
        skip("Ruby doesn't have the wrap method") unless Nokogiri.jruby?
        noko_doc = wrap_java_document
        assert_equal 'foo', noko_doc.root.name

        noko_doc = Nokogiri::XML(<<eoxml)
<foo xmlns='hello'>
  <bar xmlns:foo='world' />
</foo>
eoxml
        dom = noko_doc.to_java
        assert dom.kind_of? org.w3c.dom.Document
        assert_equal 'foo', dom.getDocumentElement().getTagName()
      end

      def test_add_child
        skip("Ruby doesn't have the wrap method") unless Nokogiri.jruby?
        doc = wrap_java_document
        doc.root.add_child "<bar />"
      end

      def test_can_be_closed
        f = File.open XML_FILE
        Nokogiri::XML f
        f.close
      end
    end
  end
end
