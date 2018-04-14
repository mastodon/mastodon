module Nokogiri
  module CSS
    class Node
      ALLOW_COMBINATOR_ON_SELF = [:DIRECT_ADJACENT_SELECTOR, :FOLLOWING_SELECTOR, :CHILD_SELECTOR]

      # Get the type of this node
      attr_accessor :type
      # Get the value of this node
      attr_accessor :value

      # Create a new Node with +type+ and +value+
      def initialize type, value
        @type = type
        @value = value
      end

      # Accept +visitor+
      def accept visitor
        visitor.send(:"visit_#{type.to_s.downcase}", self)
      end

      ###
      # Convert this CSS node to xpath with +prefix+ using +visitor+
      def to_xpath prefix = '//', visitor = XPathVisitor.new
        prefix = '.' if ALLOW_COMBINATOR_ON_SELF.include?(type) && value.first.nil?
        prefix + visitor.accept(self)
      end

      # Find a node by type using +types+
      def find_by_type types
        matches = []
        matches << self if to_type == types
        @value.each do |v|
          matches += v.find_by_type(types) if v.respond_to?(:find_by_type)
        end
        matches
      end

      # Convert to_type
      def to_type
        [@type] + @value.map { |n|
          n.to_type if n.respond_to?(:to_type)
        }.compact
      end

      # Convert to array
      def to_a
        [@type] + @value.map { |n| n.respond_to?(:to_a) ? n.to_a : [n] }
      end
    end
  end
end
