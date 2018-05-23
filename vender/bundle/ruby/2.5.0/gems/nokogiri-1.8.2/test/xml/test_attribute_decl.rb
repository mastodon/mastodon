require "helper"

module Nokogiri
  module XML
    class TestAttributeDecl < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(<<-eoxml)
<?xml version="1.0"?><?TEST-STYLE PIDATA?>
<!DOCTYPE staff SYSTEM "staff.dtd" [
   <!ATTLIST br width CDATA "0">
   <!ATTLIST a width CDATA "0">
   <!ATTLIST payment type (check|cash) "cash">
]>
<root />
        eoxml
        @attrs = @xml.internal_subset.children
        @attr_decl = @attrs.first
      end

      def test_inspect
        assert_equal(
          "#<#{@attr_decl.class.name}:#{sprintf("0x%x", @attr_decl.object_id)} #{@attr_decl.to_s.inspect}>",
          @attr_decl.inspect
        )
      end

      def test_type
        assert_equal 16, @attr_decl.type
      end

      def test_class
        assert_instance_of Nokogiri::XML::AttributeDecl, @attr_decl
      end

      def test_content
        assert_raise NoMethodError do
          @attr_decl.content
        end
      end

      def test_attributes
        assert_raise NoMethodError do
          @attr_decl.attributes
        end
      end

      def test_namespace
        assert_raise NoMethodError do
          @attr_decl.namespace
        end
      end

      def test_namespace_definitions
        assert_raise NoMethodError do
          @attr_decl.namespace_definitions
        end
      end

      def test_line
        assert_raise NoMethodError do
          @attr_decl.line
        end
      end

      def test_attribute_type
        if Nokogiri.uses_libxml?
          assert_equal 1, @attr_decl.attribute_type
        else
          assert_equal 'CDATA', @attr_decl.attribute_type
        end
      end

      def test_default
        assert_equal '0', @attr_decl.default
        assert_equal '0', @attrs[1].default
      end

      def test_enumeration
        assert_equal [], @attr_decl.enumeration
        assert_equal ['check', 'cash'], @attrs[2].enumeration
      end
    end
  end
end

