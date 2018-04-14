require "helper"

module Nokogiri
  module XML
    class TestDocumentFragment < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
      end

      def test_replace_text_node
        html = "foo"
        doc = Nokogiri::XML::DocumentFragment.parse(html)
        doc.children[0].replace "bar"
        assert_equal 'bar', doc.children[0].content
      end

      def test_fragment_is_relative
        doc      = Nokogiri::XML('<root><a xmlns="blah" /></root>')
        ctx      = doc.root.child
        fragment = Nokogiri::XML::DocumentFragment.new(doc, '<hello />', ctx)
        hello    = fragment.child

        assert_equal 'hello', hello.name
        assert_equal doc.root.child.namespace, hello.namespace
      end

      def test_node_fragment_is_relative
        doc      = Nokogiri::XML('<root><a xmlns="blah" /></root>')
        assert doc.root.child
        fragment = doc.root.child.fragment('<hello />')
        hello    = fragment.child

        assert_equal 'hello', hello.name
        assert_equal doc.root.child.namespace, hello.namespace
      end

      def test_new
        assert Nokogiri::XML::DocumentFragment.new(@xml)
      end

      def test_fragment_should_have_document
        fragment = Nokogiri::XML::DocumentFragment.new(@xml)
        assert_equal @xml, fragment.document
      end

      def test_name
        fragment = Nokogiri::XML::DocumentFragment.new(@xml)
        assert_equal '#document-fragment', fragment.name
      end

      def test_static_method
        fragment = Nokogiri::XML::DocumentFragment.parse("<div>a</div>")
        assert_instance_of Nokogiri::XML::DocumentFragment, fragment
      end

      def test_static_method_with_namespaces
        # follows different path in FragmentHandler#start_element which blew up after 597195ff
        fragment = Nokogiri::XML::DocumentFragment.parse("<o:div>a</o:div>")
        assert_instance_of Nokogiri::XML::DocumentFragment, fragment
      end

      def test_many_fragments
        100.times { Nokogiri::XML::DocumentFragment.new(@xml) }
      end

      def test_subclass
        klass = Class.new(Nokogiri::XML::DocumentFragment)
        fragment = klass.new(@xml, "<div>a</div>")
        assert_instance_of klass, fragment
      end

      def test_subclass_parse
        klass = Class.new(Nokogiri::XML::DocumentFragment)
        doc = klass.parse("<div>a</div>")
        assert_instance_of klass, doc
      end

      def test_unparented_text_node_parse
        fragment = Nokogiri::XML::DocumentFragment.parse("foo")
        fragment.children.after("<bar/>")
      end

      def test_xml_fragment
        fragment = Nokogiri::XML.fragment("<div>a</div>")
        assert_equal "<div>a</div>", fragment.to_s
      end

      def test_xml_fragment_has_multiple_toplevel_children
        doc = "<div>b</div><div>e</div>"
        fragment = Nokogiri::XML::Document.new.fragment(doc)
        assert_equal "<div>b</div><div>e</div>", fragment.to_s
      end

      def test_xml_fragment_has_outer_text
        # this test is descriptive, not prescriptive.
        doc = "a<div>b</div>"
        fragment = Nokogiri::XML::Document.new.fragment(doc)
        assert_equal "a<div>b</div>", fragment.to_s

        doc = "<div>b</div>c"
        fragment = Nokogiri::XML::Document.new.fragment(doc)
        assert_equal "<div>b</div>c", fragment.to_s
      end

      def test_xml_fragment_case_sensitivity
        doc = "<crazyDiv>b</crazyDiv>"
        fragment = Nokogiri::XML::Document.new.fragment(doc)
        assert_equal "<crazyDiv>b</crazyDiv>", fragment.to_s
      end

      def test_xml_fragment_with_leading_whitespace
        doc = "     <div>b</div>  "
        fragment = Nokogiri::XML::Document.new.fragment(doc)
        assert_equal "     <div>b</div>  ", fragment.to_s
      end

      def test_xml_fragment_with_leading_whitespace_and_newline
        doc = "     \n<div>b</div>  "
        fragment = Nokogiri::XML::Document.new.fragment(doc)
        assert_equal "     \n<div>b</div>  ", fragment.to_s
      end

      def test_fragment_children_search
        fragment = Nokogiri::XML::Document.new.fragment(
          '<div><p id="content">hi</p></div>'
        )
        expected = fragment.children.xpath('.//p')
        assert_equal 1, expected.length

        css          = fragment.children.css('p')
        search_css   = fragment.children.search('p')
        search_xpath = fragment.children.search('.//p')
        assert_equal expected, css
        assert_equal expected, search_css
        assert_equal expected, search_xpath
      end

      def test_fragment_css_search_with_whitespace_and_node_removal
        # The same xml without leading whitespace in front of the first line
        # does not expose the error. Putting both nodes on the same line
        # instead also fixes the crash.
        fragment = Nokogiri::XML::DocumentFragment.parse <<-EOXML
          <p id="content">hi</p> x <!--y--> <p>another paragraph</p>
        EOXML
        children = fragment.css('p')
        assert_equal 2, children.length
        # removing the last node instead does not yield the error. Probably the
        # node removal leaves around two consecutive text nodes which make the
        # css search crash?
        children.first.remove
        assert_equal 1, fragment.xpath('.//p | self::p').length
        assert_equal 1, fragment.css('p').length
      end

      def test_fragment_search_three_ways
        frag = Nokogiri::XML::Document.new.fragment '<p id="content">foo</p><p id="content">bar</p>'
        expected = frag.xpath('./*[@id = "content"]')
        assert_equal 2, expected.length

        [
          [:css, '#content'],
          [:search, '#content'],
          [:search, './*[@id = \'content\']'],
        ].each do |method, query|
          result = frag.send(method, query)
          assert_equal(expected, result,
            "fragment search with :#{method} using '#{query}' expected '#{expected}' got '#{result}'")
        end
      end

      def test_fragment_search_with_multiple_queries
        xml = '<thing>
                 <div class="title">important thing</div>
               </thing>
               <thing>
                 <div class="content">stuff</div>
               </thing>
               <thing>
                 <p class="blah">more stuff</div>
               </thing>'
        fragment = Nokogiri::XML.fragment(xml)
        assert_kind_of Nokogiri::XML::DocumentFragment, fragment

        assert_equal 3, fragment.xpath('.//div', './/p').length
        assert_equal 3, fragment.css('.title', '.content', 'p').length
        assert_equal 3, fragment.search('.//div', 'p.blah').length
      end

      def test_fragment_without_a_namespace_does_not_get_a_namespace
        doc = Nokogiri::XML <<-EOX
          <root xmlns="http://tenderlovemaking.com/" xmlns:foo="http://flavorjon.es/" xmlns:bar="http://google.com/">
            <foo:existing></foo:existing>
          </root>
        EOX
        frag = doc.fragment "<newnode></newnode>"
        assert_nil frag.namespace
      end

      def test_fragment_namespace_resolves_against_document_root
        doc = Nokogiri::XML <<-EOX
          <root xmlns:foo="http://flavorjon.es/" xmlns:bar="http://google.com/">
            <foo:existing></foo:existing>
          </root>
        EOX
        ns = doc.root.namespace_definitions.detect { |x| x.prefix == "bar" }

        frag = doc.fragment "<bar:newnode></bar:newnode>"
        assert frag.children.first.namespace
        assert_equal ns, frag.children.first.namespace
      end

      def test_fragment_invalid_namespace_is_silently_ignored
        doc = Nokogiri::XML <<-EOX
          <root xmlns:foo="http://flavorjon.es/" xmlns:bar="http://google.com/">
            <foo:existing></foo:existing>
          </root>
        EOX
        frag = doc.fragment "<baz:newnode></baz:newnode>"
        assert_nil frag.children.first.namespace
      end

      def test_decorator_is_applied
        x = Module.new do
          def awesome!
          end
        end
        util_decorate(@xml, x)
        fragment = Nokogiri::XML::DocumentFragment.new(@xml, "<div>a</div><div>b</div>")

        assert node_set = fragment.css('div')
        assert node_set.respond_to?(:awesome!)
        node_set.each do |node|
          assert node.respond_to?(:awesome!), node.class
        end
        assert fragment.children.respond_to?(:awesome!), fragment.children.class
      end

      def test_decorator_is_applied_to_empty_set
        x = Module.new do
          def awesome!
          end
        end
        util_decorate(@xml, x)
        fragment = Nokogiri::XML::DocumentFragment.new(@xml, "")
        assert fragment.children.respond_to?(:awesome!), fragment.children.class
      end

      def test_add_node_to_doc_fragment_segfault
        frag = Nokogiri::XML::DocumentFragment.new(@xml, '<p>hello world</p>')
        Nokogiri::XML::Comment.new(frag,'moo')
      end

      def test_issue_1077_parsing_of_frozen_strings
        input = <<-EOS
<?xml version="1.0" encoding="utf-8"?>
<library>
  <book title="I like turtles"/>
</library>
EOS
        input.freeze

        Nokogiri::XML::DocumentFragment.parse(input) # assert_nothing_raised
      end

      if Nokogiri.uses_libxml?
        def test_for_libxml_in_context_fragment_parsing_bug_workaround
          10.times do
            begin
              fragment = Nokogiri::XML.fragment("<div></div>")
              parent = fragment.children.first
              child = parent.parse("<h1></h1>").first
              parent.add_child child
            end
            GC.start
          end
        end

        def test_for_libxml_in_context_memory_badness_when_encountering_encoding_errors
          # see issue #643 for background
          # this test exists solely to raise an error during valgrind test runs.
          html = <<-EOHTML
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=shizzle" />
  </head>
  <body>
    <div>Foo</div>
  </body>
</html>
EOHTML
          doc = Nokogiri::HTML html
          doc.at_css("div").replace("Bar")
        end
      end
    end
  end
end
