require "helper"

module Nokogiri
  module XML
    class TestNamespacesInBuilderDoc < Nokogiri::TestCase
      def setup
        super
        b = Nokogiri::XML::Builder.new do |x|
          x.fruit(:xmlns => 'ns:fruit', :'xmlns:veg' => 'ns:veg', :'xmlns:xlink' => 'http://www.w3.org/1999/xlink') do
            x.pear { x.bosc }
            x.orange
            x[:veg].carrot do
              x.cheese(:xmlns => 'ns:dairy', :'xlink:href' => 'http://example.com/cheese/')
            end
            x[:meat].bacon(:'xmlns:meat' => 'ns:meat') do
              x.apple :count => 2
              x[:veg].tomato
            end
          end
        end

        @doc = b.doc
      end

      def check_namespace e
        e.namespace.nil? ? nil : e.namespace.href
      end

      def test_builder_default_ns
        assert_equal 'ns:fruit', check_namespace(@doc.root)
      end
      def test_builder_parent_default_ns
        assert_equal 'ns:fruit', check_namespace(@doc.root.elements[0])
        assert_equal 'ns:fruit', check_namespace(@doc.root.elements[1])
      end
      def test_builder_grandparent_default_ns
        assert_equal 'ns:fruit', check_namespace(@doc.root.elements[0].elements[0])
      end
      def test_builder_parent_nondefault_ns
        assert_equal 'ns:veg',   check_namespace(@doc.root.elements[2])
      end
      def test_builder_single_decl_ns_1
        assert_equal 'ns:dairy', check_namespace(@doc.root.elements[2].elements[0])
      end
      def test_builder_nondefault_attr_ns
        assert_equal 'http://www.w3.org/1999/xlink', 
          check_namespace(@doc.root.elements[2].elements[0].attribute_nodes.find { |a| a.name =~ /href/ })
      end
      def test_builder_single_decl_ns_2
        assert_equal 'ns:meat',  check_namespace(@doc.root.elements[3])
      end
      def test_builder_buried_default_ns
        assert_equal 'ns:fruit',  check_namespace(@doc.root.elements[3].elements[0])
      end
      def test_builder_buried_decl_ns
        assert_equal 'ns:veg',  check_namespace(@doc.root.elements[3].elements[1])
      end
      def test_builder_namespace_count
        n = @doc.root.clone
        n.children.each(&:remove)
        ns_attrs = n.to_xml.scan(/\bxmlns(?::.+?)?=/)
        assert_equal 3, ns_attrs.length
      end

      def test_builder_namespaced_attribute_on_unparented_node
        doc = Nokogiri::XML::Builder.new do |x|
          x.root('xmlns:foo' => 'http://foo.io') {
            x.obj('foo:attr' => 'baz')
          }
        end.doc
        assert_equal 'http://foo.io', doc.root.children.first.attribute_nodes.first.namespace.href
      end
    end
  end
end
