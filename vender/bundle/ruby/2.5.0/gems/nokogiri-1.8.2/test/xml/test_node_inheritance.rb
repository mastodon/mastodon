# issue#560

require 'helper'

module Nokogiri
  module XML
    class TestNodeInheritance < Nokogiri::TestCase
      MyNode = Class.new Nokogiri::XML::Node
      def setup
        super
        @node = MyNode.new 'foo', Nokogiri::XML::Document.new
        @node['foo'] = 'bar' 
      end

      def test_node_name
        assert @node.name == 'foo'
      end

      def test_node_writing_an_attribute_accessing_via_attributes 
        assert @node.attributes['foo']
      end

      def test_node_writing_an_attribute_accessing_via_key 
        assert @node.key? 'foo'
      end

      def test_node_writing_an_attribute_accessing_via_brackets 
        assert @node['foo'] == 'bar'
      end
    end
  end
end
