
require 'ox'

module Ox

  # This is an alternative parser for the stdlib xmlrpc library. It makes
  # use of Ox and is based on REXMLStreamParser. To use it set is as the
  # parser for an XMLRPC client:
  #
  #   require 'xmlrpc/client'
  #   require 'ox/xmlrpc_adapter'
  #   client = XMLRPC::Client.new2('http://some_server/rpc')
  #   client.set_parser(Ox::StreamParser.new)
  class StreamParser < XMLRPC::XMLParser::AbstractStreamParser
    # Create a new instance.
    def initialize
      @parser_class = OxParser
    end

    # The SAX wrapper.
    class OxParser < Ox::Sax
      include XMLRPC::XMLParser::StreamParserMixin

      alias :text :character
      alias :end_element :endElement
      alias :start_element :startElement

      # Initiates the sax parser with the provided string.
      def parse(str)
        Ox.sax_parse(self, StringIO.new(str), :symbolize => false, :convert_special => true)
      end
    end
  end
end
