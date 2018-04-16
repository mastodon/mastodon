module Nokogiri
  module HTML
    ###
    # Nokogiri HTML builder is used for building HTML documents.  It is very
    # similar to the Nokogiri::XML::Builder.  In fact, you should go read the
    # documentation for Nokogiri::XML::Builder before reading this
    # documentation.
    #
    # == Synopsis:
    #
    # Create an HTML document with a body that has an onload attribute, and a
    # span tag with a class of "bold" that has content of "Hello world".
    #
    #   builder = Nokogiri::HTML::Builder.new do |doc|
    #     doc.html {
    #       doc.body(:onload => 'some_func();') {
    #         doc.span.bold {
    #           doc.text "Hello world"
    #         }
    #       }
    #     }
    #   end
    #   puts builder.to_html
    #
    # The HTML builder inherits from the XML builder, so make sure to read the
    # Nokogiri::XML::Builder documentation.
    class Builder < Nokogiri::XML::Builder
      ###
      # Convert the builder to HTML
      def to_html
        @doc.to_html
      end
    end
  end
end
