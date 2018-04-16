require 'oembed/formatter/base'
require 'oembed/formatter/json'
require 'oembed/formatter/xml'

module OEmbed
  # Takes the raw response from an oEmbed server and turns it into a nice Hash of data.
  module Formatter
    
    class << self
      # Returns the default format for OEmbed::Provider requests as a String.
      def default
        # Listed in order of preference.
        %w{json xml}.detect { |type| supported?(type) rescue false }
      end
      
      # Given the name of a format we want to know about (e.g. 'json'), returns 
      # true if there is a valid backend. If there is no backend, raises
      # OEmbed::FormatNotSupported.
      def supported?(format)
        case format.to_s
        when 'json'
          JSON.supported?
        when 'xml'
          XML.supported?
        else
          raise OEmbed::FormatNotSupported, format
        end
      end

      # Convert the given value into a nice Hash of values. The format should
      # be the name of the response format (e.g. 'json'). The value should be
      # a String or IO containing the response from an oEmbed server.
      # 
      # For example:
      #   value = '{"version": "1.0", "type": "link", "title": "Some Cool News Article"}'
      #   OEmbed::Formatter.decode('json', value)
      #   #=> {"version": "1.0", "type": "link", "title": "Some Cool News Article"}
      def decode(format, value)
        supported?(format)
        
        begin
          case format.to_s
          when 'json'
            begin
              JSON.decode(value)
            rescue JSON.backend.parse_error
              raise OEmbed::ParseError, $!.message
            end
          when 'xml'
            begin
              XML.decode(value)
            rescue XML.backend.parse_error
              raise OEmbed::ParseError, $!.message
            end
          end
        rescue
          raise OEmbed::ParseError, "#{$!.class}: #{$!.message}"
        end
      end
      
      # Test the given backend to make sure it parses known values correctly.
      # The backend_module should be either a JSON or XML backend.
      def test_backend(backend_module)
        expected = {
          "version"=>1.0,
          "string"=>"test",
          "int"=>42,
          "html"=>"<i>Cool's</i>\n the \"word\"!",
        }
        
        given_value = case backend_module.to_s
        when /OEmbed::Formatter::JSON::Backends::/
          <<-JSON
{"version":"1.0", "string":"test", "int":42,"html":"<i>Cool's</i>\\n the \\"word\\"\\u0021"}
          JSON
        when /OEmbed::Formatter::XML::Backends::/
          <<-XML
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<oembed>
  <version>1.0</version>
  <string>test</string>
  <int>42</int>
  <html>&lt;i&gt;Cool's&lt;/i&gt;\n the &quot;word&quot;&#x21;</html>
</oembed>
          XML
        else
          nil
        end
        
        actual = backend_module.decode(given_value)
        
        # For the test to be true the actual output Hash should have the
        # exact same list of keys _and_ the values should be the same
        # if we ignoring typecasting.
        actual.keys.sort == expected.keys.sort &&
          !actual.detect { |key, value| value.to_s != expected[key].to_s }
      end
      
    end # self
    
  end
end
