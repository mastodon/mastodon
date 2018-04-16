module Nokogiri
  module XML
    ###
    # Parse options for passing to Nokogiri.XML or Nokogiri.HTML
    #
    # == Building combinations of parse options
    # You can build your own combinations of these parse options by using any of the following methods:
    # *Note*: All examples attempt to set the +RECOVER+ & +NOENT+ options. All examples use Ruby 2 optional parameter syntax.
    # [Ruby's bitwise operators] You can use the Ruby bitwise operators to set various combinations.
    #   Nokogiri.XML('<content>Chapter 1</content', options: Nokogiri::XML::ParseOptions.new((1 << 0) | (1 << 1)))
    # [Method chaining] Every option has an equivalent method in lowercase. You can chain these methods together to set various combinations.
    #   Nokogiri.XML('<content>Chapter 1</content', options: Nokogiri::XML::ParseOptions.new.recover.noent)
    # [Using Ruby Blocks] You can also setup parse combinations in the block passed to Nokogiri.XML or Nokogiri.HTML
    #   Nokogiri.XML('<content>Chapter 1</content') {|config| config.recover.noent}
    #
    # == Removing particular parse options
    # You can also remove options from an instance of +ParseOptions+ dynamically.
    # Every option has an equivalent <code>no{option}</code> method in lowercase. You can call these methods on an instance of +ParseOptions+ to remove the option.
    # Note that this is not available for +STRICT+.
    #
    #   # Setting the RECOVER & NOENT options...
    #   options = Nokogiri::XML::ParseOptions.new.recover.noent
    #   # later...
    #   options.norecover # Removes the Nokogiri::XML::ParseOptions::RECOVER option
    #   options.nonoent # Removes the Nokogiri::XML::ParseOptions::NOENT option
    #
    class ParseOptions
      # Strict parsing
      STRICT      = 0
      # Recover from errors
      RECOVER     = 1 << 0
      # Substitute entities
      NOENT       = 1 << 1
      # Load external subsets
      DTDLOAD     = 1 << 2
      # Default DTD attributes
      DTDATTR     = 1 << 3
      # validate with the DTD
      DTDVALID    = 1 << 4
      # suppress error reports
      NOERROR     = 1 << 5
      # suppress warning reports
      NOWARNING   = 1 << 6
      # pedantic error reporting
      PEDANTIC    = 1 << 7
      # remove blank nodes
      NOBLANKS    = 1 << 8
      # use the SAX1 interface internally
      SAX1        = 1 << 9
      # Implement XInclude substitution
      XINCLUDE    = 1 << 10
      # Forbid network access. Recommended for dealing with untrusted documents.
      NONET       = 1 << 11
      # Do not reuse the context dictionary
      NODICT      = 1 << 12
      # remove redundant namespaces declarations
      NSCLEAN     = 1 << 13
      # merge CDATA as text nodes
      NOCDATA     = 1 << 14
      # do not generate XINCLUDE START/END nodes
      NOXINCNODE  = 1 << 15
      # compact small text nodes; no modification of the tree allowed afterwards (will possibly crash if you try to modify the tree)
      COMPACT     = 1 << 16
      # parse using XML-1.0 before update 5
      OLD10       = 1 << 17
      # do not fixup XINCLUDE xml:base uris
      NOBASEFIX   = 1 << 18
      # relax any hardcoded limit from the parser
      HUGE        = 1 << 19

      # the default options used for parsing XML documents
      DEFAULT_XML  = RECOVER | NONET
      # the default options used for parsing HTML documents
      DEFAULT_HTML = RECOVER | NOERROR | NOWARNING | NONET

      attr_accessor :options
      def initialize options = STRICT
        @options = options
      end

      constants.each do |constant|
        next if constant.to_sym == :STRICT
        class_eval %{
          def #{constant.downcase}
            @options |= #{constant}
            self
          end

          def no#{constant.downcase}
            @options &= ~#{constant}
            self
          end

          def #{constant.downcase}?
            #{constant} & @options == #{constant}
          end
        }
      end

      def strict
        @options &= ~RECOVER
        self
      end

      def strict?
        @options & RECOVER == STRICT
      end

      alias :to_i :options

      def inspect
        options = []
        self.class.constants.each do |k|
          options << k.downcase if send(:"#{k.downcase}?")
        end
        super.sub(/>$/, " " + options.join(', ') + ">")
      end
    end
  end
end
