module Nokogiri
  module XML
    class XPathContext

      ###
      # Register namespaces in +namespaces+
      def register_namespaces(namespaces)
        namespaces.each do |k, v|
          k = k.to_s.gsub(/.*:/,'') # strip off 'xmlns:' or 'xml:'
          register_ns(k, v)
        end
      end

    end
  end
end
