module Nokogiri
  module XML
    ###
    # Represents an attribute declaration in a DTD
    class AttributeDecl < Nokogiri::XML::Node
      undef_method :attribute_nodes
      undef_method :attributes
      undef_method :content
      undef_method :namespace
      undef_method :namespace_definitions
      undef_method :line if method_defined?(:line)

      def inspect
        "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{to_s.inspect}>"
      end
    end
  end
end
