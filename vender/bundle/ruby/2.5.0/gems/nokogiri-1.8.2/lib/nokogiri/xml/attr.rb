module Nokogiri
  module XML
    class Attr < Node
      alias :value :content
      alias :to_s :content
      alias :content= :value=

      private
      def inspect_attributes
        [:name, :namespace, :value]
      end
    end
  end
end
