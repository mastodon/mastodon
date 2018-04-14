module Nokogiri
  module XSLT
    ###
    # A Stylesheet represents an XSLT Stylesheet object.  Stylesheet creation
    # is done through Nokogiri.XSLT.  Here is an example of transforming
    # an XML::Document with a Stylesheet:
    #
    #   doc   = Nokogiri::XML(File.read('some_file.xml'))
    #   xslt  = Nokogiri::XSLT(File.read('some_transformer.xslt'))
    #
    #   puts xslt.transform(doc)
    #
    # See Nokogiri::XSLT::Stylesheet#transform for more transformation
    # information.
    class Stylesheet
      ###
      # Apply an XSLT stylesheet to an XML::Document.
      # +params+ is an array of strings used as XSLT parameters.
      # returns serialized document
      def apply_to document, params = []
        serialize(transform(document, params))
      end
    end
  end
end
