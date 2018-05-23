require 'tilt/template'
require 'nokogiri'

module Tilt
  # Nokogiri template implementation. See:
  # http://nokogiri.org/
  class NokogiriTemplate < Template
    DOCUMENT_HEADER = /^<\?xml version=\"1\.0\"\?>\n?/
    self.default_mime_type = 'text/xml'

    def prepare; end

    def evaluate(scope, locals)
      if data.respond_to?(:to_str)
        wrapper = proc { yield.sub(DOCUMENT_HEADER, "") } if block_given?
        super(scope, locals, &wrapper)
      else
        ::Nokogiri::XML::Builder.new.tap(&data).to_xml
      end
    end

    def precompiled_preamble(locals)
      return super if locals.include? :xml
      "xml = ::Nokogiri::XML::Builder.new { |xml| }\n#{super}"
    end

    def precompiled_postamble(locals)
      "xml.to_xml"
    end

    def precompiled_template(locals)
      data.to_str
    end
  end
end

