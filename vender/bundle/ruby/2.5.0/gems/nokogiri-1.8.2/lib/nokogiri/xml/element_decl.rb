module Nokogiri
  module XML
    class ElementDecl < Nokogiri::XML::Node
      undef_method :namespace
      undef_method :namespace_definitions
      undef_method :line if method_defined?(:line)

      def inspect
        "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{to_s.inspect}>"
      end
    end
  end
end
