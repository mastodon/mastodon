require "helper"

require 'stringio'

module Nokogiri
  module XML
    class TestUnparentedNode < Nokogiri::TestCase
      def setup
        begin
          xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
          @node = xml.at('staff')
          @node.unlink
        end
        GC.start # try to GC the document
      end

      def test_node_still_has_document
        assert @node.document
      end

      def test_add_namespace
        node = @node.at('address')
        node.unlink
        node.add_namespace('foo', 'http://tenderlovemaking.com')
        assert_equal 'http://tenderlovemaking.com', node.namespaces['xmlns:foo']
      end

      def test_write_to
        io = StringIO.new
        @node.write_to io
        io.rewind
        assert_equal @node.to_xml, io.read
      end

      def test_attribute_with_symbol
        assert_equal 'Yes', @node.css('address').first[:domestic]
      end

      def test_write_to_with_block
        called = false
        io = StringIO.new
        conf = nil
        @node.write_to io do |config|
          called = true
          conf = config
          config.format.as_html.no_empty_tags
        end
        io.rewind
        assert called
        assert_equal @node.serialize(:save_with => conf.options), io.read
      end

      %w{ xml html xhtml }.each do |type|
        define_method(:"test_write_#{type}_to") do
          io = StringIO.new
          assert @node.send(:"write_#{type}_to", io)
          io.rewind
          assert_match @node.send(:"to_#{type}"), io.read
        end
      end

      def test_serialize_with_block
        called = false
        conf = nil
        string = @node.serialize do |config|
          called = true
          conf = config
          config.format.as_html.no_empty_tags
        end
        assert called
        assert_equal @node.serialize(nil, conf.options), string
      end

      def test_values
        assert_equal %w{ Yes Yes }, @node.xpath('.//address')[1].values
      end

      def test_keys
        assert_equal %w{ domestic street }, @node.xpath('.//address')[1].keys
      end

      def test_each
        attributes = []
        @node.xpath('.//address')[1].each do |key, value|
          attributes << [key, value]
        end
        assert_equal [['domestic', 'Yes'], ['street', 'Yes']], attributes
      end

      def test_new
        assert node = Nokogiri::XML::Node.new('input', @node)
        assert_equal 1, node.node_type
      end

      def test_to_str
        assert name = @node.xpath('.//name').first
        assert_match(/Margaret/, '' + name)
        assert_equal('Margaret Martin', '' + name.children.first)
      end

      def test_ancestors
        assert(address = @node.xpath('.//address').first)
        assert_equal 2, address.ancestors.length
        assert_equal ['employee', 'staff'],
          address.ancestors.map { |x| x ? x.name : x }
      end

      def test_read_only?
        assert entity_decl = @node.internal_subset.children.find { |x|
          x.type == Node::ENTITY_DECL
        }
        assert entity_decl.read_only?
      end

      def test_remove_attribute
        address = @node.xpath('./employee/address').first
        assert_equal 'Yes', address['domestic']
        address.remove_attribute 'domestic'
        assert_nil address['domestic']
      end

      def test_delete
        address = @node.xpath('./employee/address').first
        assert_equal 'Yes', address['domestic']
        address.delete 'domestic'
        assert_nil address['domestic']
      end

      def test_add_child_in_same_document
        child = @node.css('employee').first

        assert child.children.last
        assert new_child = child.children.first

        last = child.children.last

        child.add_child(new_child)
        assert_equal new_child, child.children.last
        assert_equal last, child.children.last
      end

      def test_add_child_from_other_document
        d1 = Nokogiri::XML("<root><item>1</item><item>2</item></root>")
        d2 = Nokogiri::XML("<root><item>3</item><item>4</item></root>")

        d2.at('root').search('item').each do |i|
          d1.at('root').add_child i
        end

        assert_equal 0, d2.search('item').size
        assert_equal 4, d1.search('item').size
      end

      def test_add_child
        xml = Nokogiri::XML(<<-eoxml)
        <root>
          <a>Hello world</a>
        </root>
        eoxml
        text_node = Nokogiri::XML::Text.new('hello', xml)
        assert_equal Nokogiri::XML::Node::TEXT_NODE, text_node.type
        xml.root.add_child text_node
        assert_match 'hello', xml.to_s
      end

      def test_chevron_works_as_add_child
        xml = Nokogiri::XML(<<-eoxml)
        <root>
          <a>Hello world</a>
        </root>
        eoxml
        text_node = Nokogiri::XML::Text.new('hello', xml)
        xml.root << text_node
        assert_match 'hello', xml.to_s
      end

      def test_add_previous_sibling
        xml = Nokogiri::XML(<<-eoxml)
        <root>
          <a>Hello world</a>
        </root>
        eoxml
        b_node = Nokogiri::XML::Node.new('a', xml)
        assert_equal Nokogiri::XML::Node::ELEMENT_NODE, b_node.type
        b_node.content = 'first'
        a_node = xml.xpath('.//a').first
        a_node.add_previous_sibling(b_node)
        assert_equal('first', xml.xpath('.//a').first.text)
      end

      def test_add_previous_sibling_merge
        xml = Nokogiri::XML(<<-eoxml)
        <root>
          <a>Hello world</a>
        </root>
        eoxml

        assert a_tag = xml.css('a').first

        left_space = a_tag.previous
        right_space = a_tag.next
        assert left_space.text?
        assert right_space.text?

        left_space.add_previous_sibling(right_space)
        assert_equal left_space, right_space
      end

      def test_add_next_sibling_merge
        xml = Nokogiri::XML(<<-eoxml)
        <root>
          <a>Hello world</a>
        </root>
        eoxml

        assert a_tag = xml.css('a').first

        left_space = a_tag.previous
        right_space = a_tag.next
        assert left_space.text?
        assert right_space.text?

        right_space.add_next_sibling(left_space)
        assert_equal left_space, right_space
      end

      def test_add_next_sibling_to_root_raises_exception
        xml = Nokogiri::XML(<<-eoxml)
        <root />
        eoxml

        node = Nokogiri::XML::Node.new 'child', xml

        assert_raise(ArgumentError) do
          xml.root.add_next_sibling(node)
        end
      end

      def test_add_previous_sibling_to_root_raises_exception
        xml = Nokogiri::XML(<<-eoxml)
        <root />
        eoxml

        node = Nokogiri::XML::Node.new 'child', xml

        assert_raise(ArgumentError) do
          xml.root.add_previous_sibling(node)
        end
      end

      def test_document_root_can_have_a_comment_sibling_via_add_child
        doc = Nokogiri::XML "<root>foo</root>"
        comment = Nokogiri::XML::Comment.new(doc, "this is a comment")
        doc.add_child comment
        assert_equal [doc.root, comment], doc.children.to_a
      end

      def test_document_root_can_have_a_comment_sibling_via_prepend_child
        doc = Nokogiri::XML "<root>foo</root>"
        comment = Nokogiri::XML::Comment.new(doc, "this is a comment")
        doc.prepend_child comment
        assert_equal [comment, doc.root], doc.children.to_a
      end

      def test_document_root_can_have_a_comment_sibling_via_add_next_sibling
        doc = Nokogiri::XML "<root>foo</root>"
        comment = Nokogiri::XML::Comment.new(doc, "this is a comment")
        doc.root.add_next_sibling comment
        assert_equal [doc.root, comment], doc.children.to_a
      end

      def test_document_root_can_have_a_comment_sibling_via_add_previous_sibling
        doc = Nokogiri::XML "<root>foo</root>"
        comment = Nokogiri::XML::Comment.new(doc, "this is a comment")
        doc.root.add_previous_sibling comment
        assert_equal [comment, doc.root], doc.children.to_a
      end

      def test_document_root_can_have_a_processing_instruction_sibling_via_add_child
        doc = Nokogiri::XML "<root>foo</root>"
        pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet", %q{type="text/xsl" href="foo.xsl"})
        doc.add_child pi
        assert_equal [doc.root, pi], doc.children.to_a
      end

      def test_document_root_can_have_a_processing_instruction_sibling_via_prepend_child
        doc = Nokogiri::XML "<root>foo</root>"
        pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet", %q{type="text/xsl" href="foo.xsl"})
        doc.prepend_child pi
        assert_equal [pi, doc.root], doc.children.to_a
      end

      def test_document_root_can_have_a_processing_instruction_sibling_via_add_next_sibling
        doc = Nokogiri::XML "<root>foo</root>"
        pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet", %q{type="text/xsl" href="foo.xsl"})
        doc.root.add_next_sibling pi
        assert_equal [doc.root, pi], doc.children.to_a
      end

      def test_document_root_can_have_a_processing_instruction_sibling_via_add_previous_sibling
        doc = Nokogiri::XML "<root>foo</root>"
        pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet", %q{type="text/xsl" href="foo.xsl"})
        doc.root.add_previous_sibling pi
        assert_equal [pi, doc.root], doc.children.to_a
      end

      def test_find_by_css_with_tilde_eql
        xml = Nokogiri::XML.parse(<<-eoxml)
        <root>
          <a>Hello world</a>
          <a class='foo bar'>Bar</a>
          <a class='bar foo'>Bar</a>
          <a class='bar'>Bar</a>
          <a class='baz bar foo'>Bar</a>
          <a class='bazbarfoo'>Awesome</a>
          <a class='bazbar'>Awesome</a>
        </root>
        eoxml
        set = xml.css('a[@class~="bar"]')
        assert_equal 4, set.length
        assert_equal ['Bar'], set.map { |node| node.content }.uniq
      end

      def test_unlink
        xml = Nokogiri::XML.parse(<<-eoxml)
        <root>
          <a class='foo bar'>Bar</a>
          <a class='bar foo'>Bar</a>
          <a class='bar'>Bar</a>
          <a>Hello world</a>
          <a class='baz bar foo'>Bar</a>
          <a class='bazbarfoo'>Awesome</a>
          <a class='bazbar'>Awesome</a>
        </root>
        eoxml
        node = xml.xpath('.//a')[3]
        assert_equal('Hello world', node.text)
        assert_match(/Hello world/, xml.to_s)
        assert node.parent
        assert node.document
        assert node.previous_sibling
        assert node.next_sibling
        node.unlink
        assert !node.parent
        # assert !node.document
        assert !node.previous_sibling
        assert !node.next_sibling
        assert_no_match(/Hello world/, xml.to_s)
      end

      def test_next_sibling
        assert sibling = @node.child.next_sibling
        assert_equal('employee', sibling.name)
      end

      def test_previous_sibling
        assert sibling = @node.child.next_sibling
        assert_equal('employee', sibling.name)
        assert_equal(sibling.previous_sibling, @node.child)
      end

      def test_name=
        @node.name = 'awesome'
        assert_equal('awesome', @node.name)
      end

      def test_child
        assert child = @node.child
        assert_equal('text', child.name)
      end

      def test_key?
        assert node = @node.search('.//address').first
        assert(!node.key?('asdfasdf'))
      end

      def test_set_property
        assert node = @node.search('.//address').first
        node['foo'] = 'bar'
        assert_equal('bar', node['foo'])
      end

      def test_attributes
        assert node = @node.search('.//address').first
        assert_nil(node['asdfasdfasdf'])
        assert_equal('Yes', node['domestic'])

        assert node = @node.search('.//address')[2]
        attr = node.attributes
        assert_equal 2, attr.size
        assert_equal 'Yes', attr['domestic'].value
        assert_equal 'Yes', attr['domestic'].to_s
        assert_equal 'No', attr['street'].value
      end

      def test_path
        assert set = @node.search('.//employee')
        assert node = set.first
        assert_equal('/staff/employee[1]', node.path)
      end

      def test_search_by_symbol
        assert set = @node.search(:employee)
        assert 5, set.length

        assert node = @node.at(:employee)
        assert node.text =~ /EMP0001/
      end

      def test_new_node
        node = Nokogiri::XML::Node.new('form', @node.document)
        assert_equal('form', node.name)
        assert(node.document)
      end

      def test_encode_special_chars
        foo = @node.css('employee').first.encode_special_chars('&')
        assert_equal '&amp;', foo
      end

      def test_content
        node = Nokogiri::XML::Node.new('form', @node)
        assert_equal('', node.content)

        node.content = 'hello world!'
        assert_equal('hello world!', node.content)
      end

      def test_whitespace_nodes
        doc = Nokogiri::XML.parse("<root><b>Foo</b>\n<i>Bar</i> <p>Bazz</p></root>")
        children = doc.at('.//root').children.collect(&:to_s)
        assert_equal "\n", children[1]
        assert_equal " ", children[3]
      end

      def test_replace
        set = @node.search('.//employee')
        assert 5, set.length
        assert 0, @node.search('.//form').length

        first = set[0]
        second = set[1]

        node = Nokogiri::XML::Node.new('form', @node)
        first.replace(node)

        assert set = @node.search('.//employee')
        assert_equal 4, set.length
        assert 1, @node.search('.//form').length

        assert_equal set[0].to_xml, second.to_xml
      end

      def test_replace_on_unparented_node
        foo = Node.new('foo', @node.document)
        if Nokogiri.jruby? # JRuby Nokogiri doesn't raise an exception
          @node.replace(foo)
        else
          assert_raises(RuntimeError){ @node.replace(foo) }
        end
      end

      def test_illegal_replace_of_node_with_doc
        new_node = Nokogiri::XML.parse('<foo>bar</foo>')
        old_node = @node.at('.//employee')
        assert_raises(ArgumentError){ old_node.replace new_node }
      end

      def test_unlink_on_unlinked_node_1
        node = Nokogiri::XML::Node.new 'div', Nokogiri::XML::Document.new
        node.unlink # must_not_raise
        assert_nil node.parent
      end

      def test_unlink_on_unlinked_node_2
        node = Nokogiri::XML('<div>foo</div>').at_css("div")
        node.unlink
        node.unlink # must_not_raise
        assert_nil node.parent
      end
    end
  end
end
