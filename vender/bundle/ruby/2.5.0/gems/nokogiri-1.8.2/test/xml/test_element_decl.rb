require "helper"

module Nokogiri
  module XML
    class TestElementDecl < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(<<-eoxml)
<?xml version="1.0"?><?TEST-STYLE PIDATA?>
<!DOCTYPE staff SYSTEM "staff.dtd" [
   <!ELEMENT br EMPTY>
   <!ELEMENT div1 (head, (p | list | note)*, div2*)>
   <!ELEMENT my:way EMPTY>
   <!ATTLIST br width CDATA "0">
   <!ATTLIST br height CDATA "0">
]>
<root/>
        eoxml
        @elements = @xml.internal_subset.children.find_all { |x|
          x.type == 15
        }
      end

      def test_inspect
        e = @elements.first
        assert_equal(
          "#<#{e.class.name}:#{sprintf("0x%x", e.object_id)} #{e.to_s.inspect}>",
          e.inspect
        )
      end

      def test_prefix
        assert_nil @elements[1].prefix
        assert_equal 'my', @elements[2].prefix
      end

      def test_line
        assert_raise NoMethodError do
          @elements.first.line
        end
      end

      def test_namespace
        assert_raise NoMethodError do
          @elements.first.namespace
        end
      end

      def test_namespace_definitions
        assert_raise NoMethodError do
          @elements.first.namespace_definitions
        end
      end

      def test_element_type
        assert_equal 1, @elements.first.element_type
      end

      def test_type
        assert_equal 15, @elements.first.type
      end

      def test_class
        assert_instance_of Nokogiri::XML::ElementDecl, @elements.first
      end

      def test_attributes
        assert_equal 2, @elements.first.attribute_nodes.length
        assert_equal 'width', @elements.first.attribute_nodes.first.name
      end
    end
  end
end
