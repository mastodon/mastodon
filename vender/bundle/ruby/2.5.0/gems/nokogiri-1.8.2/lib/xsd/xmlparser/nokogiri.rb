require 'nokogiri'

module XSD # :nodoc:
  module XMLParser # :nodoc:
    ###
    # Nokogiri XML parser for soap4r.
    #
    # Nokogiri may be used as the XML parser in soap4r.  Simply require
    # 'xsd/xmlparser/nokogiri' in your soap4r applications, and soap4r
    # will use Nokogiri as it's XML parser.  No other changes should be
    # required to use Nokogiri as the XML parser.
    #
    # Example (using UW ITS Web Services):
    #
    #   require 'rubygems'
    #   require 'nokogiri'
    #   gem 'soap4r'
    #   require 'defaultDriver'
    #   require 'xsd/xmlparser/nokogiri'
    #
    #   obj = AvlPortType.new
    #   obj.getLatestByRoute(obj.getAgencies.first, 8).each do |bus|
    #     p "#{bus.routeID}, #{bus.longitude}, #{bus.latitude}"
    #   end
    #
    class Nokogiri < XSD::XMLParser::Parser
      ###
      # Create a new XSD parser with +host+ and +opt+
      def initialize host, opt = {}
        super
        @parser = ::Nokogiri::XML::SAX::Parser.new(self, @charset || 'UTF-8')
      end

      ###
      # Start parsing +string_or_readable+
      def do_parse string_or_readable
        @parser.parse(string_or_readable)
      end

      ###
      # Handle the start_element event with +name+ and +attrs+
      def start_element name, attrs = []
        super(name, Hash[*attrs.flatten])
      end

      ###
      # Handle the end_element event with +name+
      def end_element name
        super
      end

      ###
      # Handle errors with message +msg+
      def error msg
        raise ParseError.new(msg)
      end
      alias :warning :error

      ###
      # Handle cdata_blocks containing +string+
      def cdata_block string
        characters string
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
        }.flatten
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

      %w{ xmldecl start_document end_document comment }.each do |name|
        class_eval %{ def #{name}(*args); end }
      end

      add_factory(self)
    end
  end
end
