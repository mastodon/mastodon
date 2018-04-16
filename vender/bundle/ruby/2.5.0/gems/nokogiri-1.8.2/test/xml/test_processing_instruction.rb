require "helper"

module Nokogiri
  module XML
    class TestProcessingInstruction < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML.parse(File.read(XML_FILE), XML_FILE)
      end

      def test_type
        assert_equal(Node::PI_NODE, @xml.children[0].type)
      end

      def test_name
        assert_equal 'TEST-STYLE', @xml.children[0].name
      end

      def test_new
        assert ref = ProcessingInstruction.new(@xml, 'name', 'content')
        assert_instance_of ProcessingInstruction, ref
      end

      def test_many_new
        100.times { ProcessingInstruction.new(@xml, 'foo', 'bar') }
        @xml.root << ProcessingInstruction.new(@xml, 'foo', 'bar')
      end
    end
  end
end
