module Nokogiri
  module XML
    class EntityReference < Nokogiri::XML::Node
      def children
        # libxml2 will create a malformed child node for predefined
        # entities. because any use of that child is likely to cause a
        # segfault, we shall pretend that it doesn't exist.
        #
        # see https://github.com/sparklemotion/nokogiri/issues/1238 for details
        NodeSet.new(document)
      end

      def inspect_attributes
        [:name]
      end
    end
  end
end
