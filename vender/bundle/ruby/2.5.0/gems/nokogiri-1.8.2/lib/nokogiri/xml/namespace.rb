module Nokogiri
  module XML
    class Namespace
      include Nokogiri::XML::PP::Node
      attr_reader :document

      private
      def inspect_attributes
        [:prefix, :href]
      end
    end
  end
end
