require 'nokogiri/html/entity_lookup'
require 'nokogiri/html/document'
require 'nokogiri/html/document_fragment'
require 'nokogiri/html/sax/parser_context'
require 'nokogiri/html/sax/parser'
require 'nokogiri/html/sax/push_parser'
require 'nokogiri/html/element_description'
require 'nokogiri/html/element_description_defaults'

module Nokogiri
  class << self
    ###
    # Parse HTML.  Convenience method for Nokogiri::HTML::Document.parse
    def HTML thing, url = nil, encoding = nil, options = XML::ParseOptions::DEFAULT_HTML, &block
      Nokogiri::HTML::Document.parse(thing, url, encoding, options, &block)
    end
  end

  module HTML
    class << self
      ###
      # Parse HTML.  Convenience method for Nokogiri::HTML::Document.parse
      def parse thing, url = nil, encoding = nil, options = XML::ParseOptions::DEFAULT_HTML, &block
        Document.parse(thing, url, encoding, options, &block)
      end

      ####
      # Parse a fragment from +string+ in to a NodeSet.
      def fragment string, encoding = nil
        HTML::DocumentFragment.parse string, encoding
      end
    end

    # Instance of Nokogiri::HTML::EntityLookup
    NamedCharacters = EntityLookup.new
  end
end
