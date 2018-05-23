$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'nokogiri'

require 'loofah/metahelpers'
require 'loofah/elements'

require 'loofah/html5/whitelist'
require 'loofah/html5/libxml2_workarounds'
require 'loofah/html5/scrub'

require 'loofah/scrubber'
require 'loofah/scrubbers'

require 'loofah/instance_methods'
require 'loofah/xml/document'
require 'loofah/xml/document_fragment'
require 'loofah/html/document'
require 'loofah/html/document_fragment'

# == Strings and IO Objects as Input
#
# Loofah.document and Loofah.fragment accept any IO object in addition
# to accepting a string. That IO object could be a file, or a socket,
# or a StringIO, or anything that responds to +read+ and
# +close+. Which makes it particularly easy to sanitize mass
# quantities of docs.
#
module Loofah
  # The version of Loofah you are using
  VERSION = '2.2.2'

  class << self
    # Shortcut for Loofah::HTML::Document.parse
    # This method accepts the same parameters as Nokogiri::HTML::Document.parse
    def document(*args, &block)
      Loofah::HTML::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::HTML::DocumentFragment.parse
    # This method accepts the same parameters as Nokogiri::HTML::DocumentFragment.parse
    def fragment(*args, &block)
      Loofah::HTML::DocumentFragment.parse(*args, &block)
    end

    # Shortcut for Loofah.fragment(string_or_io).scrub!(method)
    def scrub_fragment(string_or_io, method)
      Loofah.fragment(string_or_io).scrub!(method)
    end

    # Shortcut for Loofah.document(string_or_io).scrub!(method)
    def scrub_document(string_or_io, method)
      Loofah.document(string_or_io).scrub!(method)
    end

    # Shortcut for Loofah::XML::Document.parse
    # This method accepts the same parameters as Nokogiri::XML::Document.parse
    def xml_document(*args, &block)
      Loofah::XML::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::XML::DocumentFragment.parse
    # This method accepts the same parameters as Nokogiri::XML::DocumentFragment.parse
    def xml_fragment(*args, &block)
      Loofah::XML::DocumentFragment.parse(*args, &block)
    end

    # Shortcut for Loofah.xml_fragment(string_or_io).scrub!(method)
    def scrub_xml_fragment(string_or_io, method)
      Loofah.xml_fragment(string_or_io).scrub!(method)
    end

    # Shortcut for Loofah.xml_document(string_or_io).scrub!(method)
    def scrub_xml_document(string_or_io, method)
      Loofah.xml_document(string_or_io).scrub!(method)
    end

    # A helper to remove extraneous whitespace from text-ified HTML
    def remove_extraneous_whitespace(string)
      string.gsub(/\n\s*\n\s*\n/,"\n\n")
    end
  end
end
