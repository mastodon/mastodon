require "helper"

module Nokogiri
  module XML
    class TestNamespacesInCreatedDoc < Nokogiri::TestCase
      def setup
        super
        @doc = Nokogiri::XML('<fruit xmlns="ns:fruit" xmlns:veg="ns:veg" xmlns:xlink="http://www.w3.org/1999/xlink"/>')
        pear = @doc.create_element('pear')
        bosc = @doc.create_element('bosc')
        pear.add_child(bosc)
        @doc.root << pear
        @doc.root.add_child('<orange/>')
        carrot = @doc.create_element('veg:carrot')
        @doc.root << carrot
        cheese = @doc.create_element('cheese', :xmlns => 'ns:dairy', :'xlink:href' => 'http://example.com/cheese/')
        carrot << cheese
        bacon = @doc.create_element('meat:bacon', :'xmlns:meat' => 'ns:meat')
        apple = @doc.create_element('apple')
        apple['count'] = 2
        bacon << apple
        tomato = @doc.create_element('veg:tomato')
        bacon << tomato
        @doc.root << bacon
      end

      def check_namespace e
        e.namespace.nil? ? nil : e.namespace.href
      end

      def test_created_default_ns
        assert_equal 'ns:fruit', check_namespace(@doc.root)
      end
      def test_created_parent_default_ns
        assert_equal 'ns:fruit', check_namespace(@doc.root.elements[0])
        assert_equal 'ns:fruit', check_namespace(@doc.root.elements[1])
      end
      def test_created_grandparent_default_ns
        assert_equal 'ns:fruit', check_namespace(@doc.root.elements[0].elements[0])
      end
      def test_created_parent_nondefault_ns
        assert_equal 'ns:veg',   check_namespace(@doc.root.elements[2])
      end
      def test_created_single_decl_ns_1
        assert_equal 'ns:dairy', check_namespace(@doc.root.elements[2].elements[0])
      end
      def test_created_nondefault_attr_ns
        assert_equal 'http://www.w3.org/1999/xlink', 
          check_namespace(@doc.root.elements[2].elements[0].attribute_nodes.find { |a| a.name =~ /href/ })
      end
      def test_created_single_decl_ns_2
        assert_equal 'ns:meat',  check_namespace(@doc.root.elements[3])
      end
      def test_created_buried_default_ns
        assert_equal 'ns:fruit',  check_namespace(@doc.root.elements[3].elements[0])
      end
      def test_created_buried_decl_ns
        assert_equal 'ns:veg',  check_namespace(@doc.root.elements[3].elements[1])
      end
      def test_created_namespace_count
        n = @doc.root.clone
        n.children.each(&:remove)
        ns_attrs = n.to_xml.scan(/\bxmlns(?::.+?)?=/)
        assert_equal 3, ns_attrs.length
      end

      def test_created_namespaced_attribute_on_unparented_node
        doc = Nokogiri::XML('<root xmlns:foo="http://foo.io"/>')
        node = @doc.create_element('obj', 'foo:attr' => 'baz')
        doc.root.add_child(node)
        assert_equal 'http://foo.io', doc.root.children.first.attribute_nodes.first.namespace.href
      end
    end
  end
end
