# Only allow this backend the xml-simple gem is already loaded
raise ::LoadError, "The xml-simple library isn't available. require 'xmlsimple'" unless defined?(XmlSimple)

module OEmbed
  module Formatter
    module XML
      module Backends
        # Use the xml-simple gem to parse XML values.
        module XmlSimple
          extend self

          # Parses an XML string or IO and convert it into an object.
          def decode(xml)
            if !xml.respond_to?(:read)
              xml = StringIO.new(xml)
            end
            ::XmlSimple.xml_in(xml, 'ForceArray'=>false)
          rescue
            case $!
            when parse_error
              raise $!
            else
              raise parse_error, "Couldn't parse the given document."
            end  
          end
          
          def decode_fail_msg
            "The version of the xml-simple library you have installed isn't parsing XML like ruby-oembed expected."
          end
          
          def parse_error
            ::ArgumentError
          end
        
        end
      end
    end
  end
end
