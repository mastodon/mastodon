module Nokogiri
  module XML
    ###
    # Represents the allowed content in an Element Declaration inside a DTD:
    #
    #   <?xml version="1.0"?><?TEST-STYLE PIDATA?>
    #   <!DOCTYPE staff SYSTEM "staff.dtd" [
    #      <!ELEMENT div1 (head, (p | list | note)*, div2*)>
    #   ]>
    #   </root>
    #
    # ElementContent represents the tree inside the <!ELEMENT> tag shown above
    # that lists the possible content for the div1 tag.
    class ElementContent
      # Possible definitions of type
      PCDATA  = 1
      ELEMENT = 2
      SEQ     = 3
      OR      = 4

      # Possible content occurrences
      ONCE    = 1
      OPT     = 2
      MULT    = 3
      PLUS    = 4

      attr_reader :document

      ###
      # Get the children of this ElementContent node
      def children
        [c1, c2].compact
      end
    end
  end
end
