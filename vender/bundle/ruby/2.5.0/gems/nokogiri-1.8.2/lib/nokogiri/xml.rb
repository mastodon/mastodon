require 'nokogiri/xml/pp'
require 'nokogiri/xml/parse_options'
require 'nokogiri/xml/sax'
require 'nokogiri/xml/searchable'
require 'nokogiri/xml/node'
require 'nokogiri/xml/attribute_decl'
require 'nokogiri/xml/element_decl'
require 'nokogiri/xml/element_content'
require 'nokogiri/xml/character_data'
require 'nokogiri/xml/namespace'
require 'nokogiri/xml/attr'
require 'nokogiri/xml/dtd'
require 'nokogiri/xml/cdata'
require 'nokogiri/xml/text'
require 'nokogiri/xml/document'
require 'nokogiri/xml/document_fragment'
require 'nokogiri/xml/processing_instruction'
require 'nokogiri/xml/node_set'
require 'nokogiri/xml/syntax_error'
require 'nokogiri/xml/xpath'
require 'nokogiri/xml/xpath_context'
require 'nokogiri/xml/builder'
require 'nokogiri/xml/reader'
require 'nokogiri/xml/notation'
require 'nokogiri/xml/entity_decl'
require 'nokogiri/xml/entity_reference'
require 'nokogiri/xml/schema'
require 'nokogiri/xml/relax_ng'

module Nokogiri
  class << self
    ###
    # Parse XML.  Convenience method for Nokogiri::XML::Document.parse
    def XML thing, url = nil, encoding = nil, options = XML::ParseOptions::DEFAULT_XML, &block
      Nokogiri::XML::Document.parse(thing, url, encoding, options, &block)
    end
  end

  module XML
    # Original C14N 1.0 spec canonicalization
    XML_C14N_1_0 =       0
    # Exclusive C14N 1.0 spec canonicalization
    XML_C14N_EXCLUSIVE_1_0 =     1
    # C14N 1.1 spec canonicalization
    XML_C14N_1_1 = 2
    class << self
      ###
      # Parse an XML document using the Nokogiri::XML::Reader API.  See
      # Nokogiri::XML::Reader for mor information
      def Reader string_or_io, url = nil, encoding = nil, options = ParseOptions::STRICT

        options = Nokogiri::XML::ParseOptions.new(options) if Integer === options
        # Give the options to the user
        yield options if block_given?

        if string_or_io.respond_to? :read
          return Reader.from_io(string_or_io, url, encoding, options.to_i)
        end
        Reader.from_memory(string_or_io, url, encoding, options.to_i)
      end

      ###
      # Parse XML.  Convenience method for Nokogiri::XML::Document.parse
      def parse thing, url = nil, encoding = nil, options = ParseOptions::DEFAULT_XML, &block
        Document.parse(thing, url, encoding, options, &block)
      end

      ####
      # Parse a fragment from +string+ in to a NodeSet.
      def fragment string
        XML::DocumentFragment.parse(string)
      end
    end
  end
end
