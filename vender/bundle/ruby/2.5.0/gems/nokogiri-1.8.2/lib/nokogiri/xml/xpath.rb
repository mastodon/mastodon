require 'nokogiri/xml/xpath/syntax_error'

module Nokogiri
  module XML
    class XPath
      # The Nokogiri::XML::Document tied to this XPath instance
      attr_accessor :document
    end
  end
end
