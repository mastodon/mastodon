require "helper"

module XSD
  module XMLParser
    class Parser
      @factory_added = nil

      class << self; attr_reader :factory_added; end

      def self.add_factory o
        @factory_added = o
      end

      def initialize *args
        @charset = nil
      end

      def characters foo
      end

      def start_element *args
      end

      def end_element *args
      end
    end
  end
end

require 'xsd/xmlparser/nokogiri'

class TestSoap4rSax < Nokogiri::TestCase
  def test_factory_added
    assert_equal XSD::XMLParser::Nokogiri, XSD::XMLParser::Nokogiri.factory_added
  end

  def test_parse
    o = Class.new(::XSD::XMLParser::Nokogiri) do
      attr_accessor :element_started
      def initialize *args
        super
        @element_started = false
      end

      def start_element *args
        @element_started = true
      end
    end.new 'foo'
    o.do_parse '<?xml version="1.0" ?><root xmlns="http://example.com/"/>'
    assert o.element_started, 'element started'
  end
end
