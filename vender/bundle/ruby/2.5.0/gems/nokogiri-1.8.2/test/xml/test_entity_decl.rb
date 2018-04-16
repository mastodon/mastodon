require "helper"

module Nokogiri
  module XML
    class TestEntityDecl < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(<<-eoxml)
<?xml version="1.0"?><?TEST-STYLE PIDATA?>
<!DOCTYPE staff SYSTEM "staff.dtd" [
   <!ENTITY ent1 "es">
   <!ENTITY nocontent "">
]>
<root />
        eoxml

        @entities = @xml.internal_subset.children
        @entity_decl = @entities.first
      end

      def test_constants
        assert_equal 1, EntityDecl::INTERNAL_GENERAL
        assert_equal 2, EntityDecl::EXTERNAL_GENERAL_PARSED
        assert_equal 3, EntityDecl::EXTERNAL_GENERAL_UNPARSED
        assert_equal 4, EntityDecl::INTERNAL_PARAMETER
        assert_equal 5, EntityDecl::EXTERNAL_PARAMETER
        assert_equal 6, EntityDecl::INTERNAL_PREDEFINED
      end

      def test_create_typed_entity
        entity = @xml.create_entity(
          'foo', EntityDecl::INTERNAL_GENERAL, nil, nil, nil
        )
        assert_equal EntityDecl::INTERNAL_GENERAL, entity.entity_type
        assert_equal 'foo', entity.name
      end

      def test_new
        entity = Nokogiri::XML::EntityDecl.new(
          'foo', @xml, EntityDecl::INTERNAL_GENERAL, nil, nil, nil
        )
        assert_equal EntityDecl::INTERNAL_GENERAL, entity.entity_type
        assert_equal 'foo', entity.name
      end

      def test_create_default_args
        entity = @xml.create_entity('foo')
        assert_equal EntityDecl::INTERNAL_GENERAL, entity.entity_type
        assert_equal 'foo', entity.name
      end

      def test_external_id
        assert_nil @entity_decl.external_id
      end

      def test_system_id
        assert_nil @entity_decl.system_id
      end

      def test_entity_type
        assert_equal 1, @entity_decl.entity_type
      end

      def test_original_content
        assert_equal "es", @entity_decl.original_content
        if Nokogiri.jruby?
          assert_nil @entities[1].original_content
        else
          assert_equal "", @entities[1].original_content
        end
      end

      def test_content
        assert_equal "es", @entity_decl.content
        if Nokogiri.jruby?
          assert_nil @entities[1].content
        else
          assert_equal "", @entities[1].content
        end
      end

      def test_type
        assert_equal 17, @entities.first.type
      end

      def test_class
        assert_instance_of Nokogiri::XML::EntityDecl, @entities.first
      end

      def test_attributes
        assert_raise NoMethodError do
          @entity_decl.attributes
        end
      end

      def test_namespace
        assert_raise NoMethodError do
          @entity_decl.namespace
        end
      end

      def test_namespace_definitions
        assert_raise NoMethodError do
          @entity_decl.namespace_definitions
        end
      end

      def test_line
        assert_raise NoMethodError do
          @entity_decl.line
        end
      end

      def test_inspect
        assert_equal(
          "#<#{@entity_decl.class.name}:#{sprintf("0x%x", @entity_decl.object_id)} #{@entity_decl.to_s.inspect}>",
          @entity_decl.inspect
        )
      end
    end
  end
end
