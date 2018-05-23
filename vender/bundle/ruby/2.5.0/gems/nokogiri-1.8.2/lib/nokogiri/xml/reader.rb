module Nokogiri
  module XML
    ###
    # Nokogiri::XML::Reader parses an XML document similar to the way a cursor
    # would move.  The Reader is given an XML document, and yields nodes
    # to an each block.
    #
    # Here is an example of usage:
    #
    #   reader = Nokogiri::XML::Reader(<<-eoxml)
    #     <x xmlns:tenderlove='http://tenderlovemaking.com/'>
    #       <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    #     </x>
    #   eoxml
    #
    #   reader.each do |node|
    #
    #     # node is an instance of Nokogiri::XML::Reader
    #     puts node.name
    #
    #   end
    #
    # Note that Nokogiri::XML::Reader#each can only be called once!!  Once
    # the cursor moves through the entire document, you must parse the
    # document again.  So make sure that you capture any information you
    # need during the first iteration.
    #
    # The Reader parser is good for when you need the speed of a SAX parser,
    # but do not want to write a Document handler.
    class Reader
      include Enumerable

      TYPE_NONE = 0
      # Element node type
      TYPE_ELEMENT = 1
      # Attribute node type
      TYPE_ATTRIBUTE = 2
      # Text node type
      TYPE_TEXT = 3
      # CDATA node type
      TYPE_CDATA = 4
      # Entity Reference node type
      TYPE_ENTITY_REFERENCE = 5
      # Entity node type
      TYPE_ENTITY = 6
      # PI node type
      TYPE_PROCESSING_INSTRUCTION = 7
      # Comment node type
      TYPE_COMMENT = 8
      # Document node type
      TYPE_DOCUMENT = 9
      # Document Type node type
      TYPE_DOCUMENT_TYPE = 10
      # Document Fragment node type
      TYPE_DOCUMENT_FRAGMENT = 11
      # Notation node type
      TYPE_NOTATION = 12
      # Whitespace node type
      TYPE_WHITESPACE = 13
      # Significant Whitespace node type
      TYPE_SIGNIFICANT_WHITESPACE = 14
      # Element end node type
      TYPE_END_ELEMENT = 15
      # Entity end node type
      TYPE_END_ENTITY = 16
      # XML Declaration node type
      TYPE_XML_DECLARATION = 17

      # A list of errors encountered while parsing
      attr_accessor :errors

      # The encoding for the document
      attr_reader :encoding

      # The XML source
      attr_reader :source

      alias :self_closing? :empty_element?

      def initialize source, url = nil, encoding = nil # :nodoc:
        @source   = source
        @errors   = []
        @encoding = encoding
      end
      private :initialize

      ###
      # Get a list of attributes for the current node.
      def attributes
        Hash[attribute_nodes.map { |node|
          [node.name, node.to_s]
        }].merge(namespaces || {})
      end

      ###
      # Get a list of attributes for the current node
      def attribute_nodes
        nodes = attr_nodes
        nodes.each { |v| v.instance_variable_set(:@_r, self) }
        nodes
      end

      ###
      # Move the cursor through the document yielding the cursor to the block
      def each
        while cursor = self.read
          yield cursor
        end
      end
    end
  end
end
