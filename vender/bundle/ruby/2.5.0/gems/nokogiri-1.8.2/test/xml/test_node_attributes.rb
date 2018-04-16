require "helper"

module Nokogiri
  module XML
    class TestNodeAttributes < Nokogiri::TestCase
      def test_attribute_with_ns
        doc = Nokogiri::XML <<-eoxml
          <root xmlns:tlm='http://tenderlovemaking.com/'>
            <node tlm:foo='bar' foo='baz' />
          </root>
        eoxml

        node = doc.at('node')

        assert_equal 'bar',
          node.attribute_with_ns('foo', 'http://tenderlovemaking.com/').value
      end

      def test_prefixed_attributes
        doc = Nokogiri::XML "<root xml:lang='en-GB' />"

        node = doc.root

        assert_equal 'en-GB', node['xml:lang']
        assert_equal 'en-GB', node.attributes['lang'].value
        assert_equal nil, node['lang']
      end

      def test_unknown_namespace_prefix_should_not_be_removed
        doc = Nokogiri::XML ''
        elem = doc.create_element 'foo', 'bar:attr' => 'something'
        assert_equal elem.attribute_nodes.first.name, 'bar:attr'
      end

      def test_set_prefixed_attributes
        doc = Nokogiri::XML %Q{<root xmlns:foo="x"/>}

        node = doc.root

        node['xml:lang'] = 'en-GB'
        node['foo:bar']  = 'bazz'

        assert_equal 'en-GB', node['xml:lang']
        assert_equal 'en-GB', node.attributes['lang'].value
        assert_equal nil, node['lang']
        assert_equal 'http://www.w3.org/XML/1998/namespace', node.attributes['lang'].namespace.href

        assert_equal 'bazz', node['foo:bar']
        assert_equal 'bazz', node.attributes['bar'].value
        assert_equal nil, node['bar']
        assert_equal 'x', node.attributes['bar'].namespace.href
      end

      def test_append_child_namespace_definitions_prefixed_attributes
        doc = Nokogiri::XML "<root/>"
        node = doc.root

        node['xml:lang'] = 'en-GB'

        assert_equal [], node.namespace_definitions.map(&:prefix)

        child_node = Nokogiri::XML::Node.new 'foo', doc
        node << child_node

        assert_equal [], node.namespace_definitions.map(&:prefix)
      end

      def test_append_child_element_with_prefixed_attributes
        doc = Nokogiri::XML "<root/>"
        node = doc.root

        assert_equal [], node.namespace_definitions.map(&:prefix)


        # assert_nothing_raised do
          child_node = Nokogiri::XML::Node.new 'foo', doc
          child_node['xml:lang'] = 'en-GB'

          node << child_node
        # end

        assert_equal [], child_node.namespace_definitions.map(&:prefix)
      end

      def test_namespace_key?
        doc = Nokogiri::XML <<-eoxml
          <root xmlns:tlm='http://tenderlovemaking.com/'>
            <node tlm:foo='bar' foo='baz' />
          </root>
        eoxml

        node = doc.at('node')

        assert node.namespaced_key?('foo', 'http://tenderlovemaking.com/')
        assert node.namespaced_key?('foo', nil)
        assert !node.namespaced_key?('foo', 'foo')
      end

      def test_set_attribute_frees_nodes # testing a segv
        skip("JRuby doesn't do GC.") if Nokogiri.jruby?
        document = Nokogiri::XML.parse("<foo></foo>")

        node = document.root
        node['visible'] = 'foo'
        attribute = node.attribute('visible')
        text = Nokogiri::XML::Text.new 'bar', document
        attribute.add_child(text)

        stress_memory_while do
          node['visible'] = 'attr'
        end
      end
    end
  end
end
