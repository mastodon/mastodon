module Nokogiri
  module XML
    class Node
      ###
      # Save options for serializing nodes
      class SaveOptions
        # Format serialized xml
        FORMAT          = 1
        # Do not include declarations
        NO_DECLARATION  = 2
        # Do not include empty tags
        NO_EMPTY_TAGS   = 4
        # Do not save XHTML
        NO_XHTML        = 8
        # Save as XHTML
        AS_XHTML        = 16
        # Save as XML
        AS_XML          = 32
        # Save as HTML
        AS_HTML         = 64

        if Nokogiri.jruby?
          # Save builder created document
          AS_BUILDER    = 128
          # the default for XML documents
          DEFAULT_XML  = AS_XML # https://github.com/sparklemotion/nokogiri/issues/#issue/415
          # the default for HTML document
          DEFAULT_HTML = NO_DECLARATION | NO_EMPTY_TAGS | AS_HTML
        else
          # the default for XML documents
          DEFAULT_XML  = FORMAT | AS_XML
          # the default for HTML document
          DEFAULT_HTML = FORMAT | NO_DECLARATION | NO_EMPTY_TAGS | AS_HTML
        end
        # the default for XHTML document
        DEFAULT_XHTML = FORMAT | NO_DECLARATION | NO_EMPTY_TAGS | AS_XHTML

        # Integer representation of the SaveOptions
        attr_reader :options

        # Create a new SaveOptions object with +options+
        def initialize options = 0; @options = options; end

        constants.each do |constant|
          class_eval %{
            def #{constant.downcase}
              @options |= #{constant}
              self
            end

            def #{constant.downcase}?
              #{constant} & @options == #{constant}
            end
          }
        end

        alias :to_i :options
      end
    end
  end
end
