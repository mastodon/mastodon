# Unlike other backends, require REXML if it's not already loaded
require 'rexml/document' unless defined?(REXML)

module OEmbed
  module Formatter
    module XML
      module Backends
        # Use the REXML library, part of the standard library, to parse XML values.
        module REXML
          extend self

          # Parses an XML string or IO and convert it into an object
          def decode(xml)
            if !xml.respond_to?(:read)
              xml = StringIO.new(xml)
            end
            obj = {}
            doc = ::REXML::Document.new(xml)
            doc.elements[1].elements.each do |el|
              obj[el.name] = el.text
            end
            obj
          rescue
            case $!
            when parse_error
              raise $!
            else
              raise parse_error, "Couldn't parse the given document."
            end  
          end
          
          def decode_fail_msg
            "The version of the REXML library you have installed isn't parsing XML like ruby-oembed expected."
          end
          
          def parse_error
            ::REXML::ParseException
          end
        
        end
      end
    end
  end
end
