require "helper"

module Nokogiri
  module XML
    class Node
      class TestSubclass < Nokogiri::TestCase
        {
          Nokogiri::XML::CDATA                  => 'doc, "foo"',
          Nokogiri::XML::Attr                   => 'doc, "foo"',
          Nokogiri::XML::Comment                => 'doc, "foo"',
          Nokogiri::XML::EntityReference        => 'doc, "foo"',
          Nokogiri::XML::ProcessingInstruction  => 'doc, "foo", "bar"',
          Nokogiri::XML::DocumentFragment       => 'doc',
          Nokogiri::XML::Node                   => '"foo", doc',
          Nokogiri::XML::Text                   => '"foo", doc',
        }.each do |klass, constructor|
          class_eval %{
            def test_subclass_#{klass.name.gsub('::', '_')}
              doc = Nokogiri::XML::Document.new
              klass = Class.new(#{klass.name})
              node = klass.new(#{constructor})
              assert_instance_of klass, node
            end
          }

          class_eval <<-eocode, __FILE__, __LINE__ + 1
            def test_subclass_initialize_#{klass.name.gsub('::', '_')}
              doc = Nokogiri::XML::Document.new
              klass = Class.new(#{klass.name}) do
                attr_accessor :initialized_with

                def initialize *args
                  @initialized_with = args
                end
              end
              node = klass.new(#{constructor}, 1)
              assert_equal [#{constructor}, 1], node.initialized_with
            end
          eocode
        end
      end
    end
  end
end
