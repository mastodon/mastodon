module Nokogiri
  module XML
    class DTD < Nokogiri::XML::Node
      undef_method :attribute_nodes
      undef_method :values
      undef_method :content
      undef_method :namespace
      undef_method :namespace_definitions
      undef_method :line if method_defined?(:line)

      def keys
        attributes.keys
      end

      def each
        attributes.each do |key, value|
          yield([key, value])
        end
      end

      def html_dtd?
        name.casecmp('html').zero?
      end

      def html5_dtd?
        html_dtd? &&
          external_id.nil? &&
          (system_id.nil? || system_id == 'about:legacy-compat')
      end
    end
  end
end
