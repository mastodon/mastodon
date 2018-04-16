module Nokogiri
  module XML
    ###
    # SAX Parsers are event driven parsers.  Nokogiri provides two different
    # event based parsers when dealing with XML.  If you want to do SAX style
    # parsing using HTML, check out Nokogiri::HTML::SAX.
    #
    # The basic way a SAX style parser works is by creating a parser,
    # telling the parser about the events we're interested in, then giving
    # the parser some XML to process.  The parser will notify you when
    # it encounters events you said you would like to know about.
    #
    # To register for events, you simply subclass Nokogiri::XML::SAX::Document,
    # and implement the methods for which you would like notification.
    #
    # For example, if I want to be notified when a document ends, and when an
    # element starts, I would write a class like this:
    #
    #   class MyDocument < Nokogiri::XML::SAX::Document
    #     def end_document
    #       puts "the document has ended"
    #     end
    #
    #     def start_element name, attributes = []
    #       puts "#{name} started"
    #     end
    #   end
    #
    # Then I would instantiate a SAX parser with this document, and feed the
    # parser some XML
    #
    #   # Create a new parser
    #   parser = Nokogiri::XML::SAX::Parser.new(MyDocument.new)
    #
    #   # Feed the parser some XML
    #   parser.parse(File.open(ARGV[0]))
    #
    # Now my document handler will be called when each node starts, and when
    # then document ends.  To see what kinds of events are available, take
    # a look at Nokogiri::XML::SAX::Document.
    #
    # Two SAX parsers for XML are available, a parser that reads from a string
    # or IO object as it feels necessary, and a parser that lets you spoon
    # feed it XML.  If you want to let Nokogiri deal with reading your XML,
    # use the Nokogiri::XML::SAX::Parser.  If you want to have fine grain
    # control over the XML input, use the Nokogiri::XML::SAX::PushParser.
    module SAX
      ###
      # This class is used for registering types of events you are interested
      # in handling.  All of the methods on this class are available as
      # possible events while parsing an XML document.  To register for any
      # particular event, just subclass this class and implement the methods
      # you are interested in knowing about.
      #
      # To only be notified about start and end element events, write a class
      # like this:
      #
      #   class MyDocument < Nokogiri::XML::SAX::Document
      #     def start_element name, attrs = []
      #       puts "#{name} started!"
      #     end
      #
      #     def end_element name
      #       puts "#{name} ended"
      #     end
      #   end
      #
      # You can use this event handler for any SAX style parser included with
      # Nokogiri.  See Nokogiri::XML::SAX, and Nokogiri::HTML::SAX.
      class Document
        ###
        # Called when an XML declaration is parsed
        def xmldecl version, encoding, standalone
        end

        ###
        # Called when document starts parsing
        def start_document
        end

        ###
        # Called when document ends parsing
        def end_document
        end

        ###
        # Called at the beginning of an element
        # * +name+ is the name of the tag
        # * +attrs+ are an assoc list of namespaces and attributes, e.g.:
        #     [ ["xmlns:foo", "http://sample.net"], ["size", "large"] ]
        def start_element name, attrs = []
        end

        ###
        # Called at the end of an element
        # +name+ is the tag name
        def end_element name
        end

        ###
        # Called at the beginning of an element
        # +name+ is the element name
        # +attrs+ is a list of attributes
        # +prefix+ is the namespace prefix for the element
        # +uri+ is the associated namespace URI
        # +ns+ is a hash of namespace prefix:urls associated with the element
        def start_element_namespace name, attrs = [], prefix = nil, uri = nil, ns = []
          ###
          # Deal with SAX v1 interface
          name = [prefix, name].compact.join(':')
          attributes = ns.map { |ns_prefix,ns_uri|
            [['xmlns', ns_prefix].compact.join(':'), ns_uri]
          } + attrs.map { |attr|
            [[attr.prefix, attr.localname].compact.join(':'), attr.value]
          }
          start_element name, attributes
        end

        ###
        # Called at the end of an element
        # +name+ is the element's name
        # +prefix+ is the namespace prefix associated with the element
        # +uri+ is the associated namespace URI
        def end_element_namespace name, prefix = nil, uri = nil
          ###
          # Deal with SAX v1 interface
          end_element [prefix, name].compact.join(':')
        end

        ###
        # Characters read between a tag.  This method might be called multiple
        # times given one contiguous string of characters.
        #
        # +string+ contains the character data
        def characters string
        end

        ###
        # Called when comments are encountered
        # +string+ contains the comment data
        def comment string
        end

        ###
        # Called on document warnings
        # +string+ contains the warning
        def warning string
        end

        ###
        # Called on document errors
        # +string+ contains the error
        def error string
        end

        ###
        # Called when cdata blocks are found
        # +string+ contains the cdata content
        def cdata_block string
        end

        ###
        # Called when processing instructions are found
        # +name+ is the target of the instruction
        # +content+ is the value of the instruction
        def processing_instruction name, content
        end
      end
    end
  end
end
