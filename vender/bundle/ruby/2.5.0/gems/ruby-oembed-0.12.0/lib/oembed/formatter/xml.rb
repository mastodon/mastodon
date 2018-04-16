module OEmbed
  module Formatter
    # Handles parsing XML values using the best available backend.
    module XML
      # A Array of all available backends, listed in order of preference.
      DECODERS = %w(XmlSimple REXML)
      
      class << self
        include ::OEmbed::Formatter::Base
        
        # Returns the current XML backend.
        def backend
          set_default_backend unless defined?(@backend)
          raise OEmbed::FormatNotSupported, :xml unless defined?(@backend)
          @backend
        end
        
        def set_default_backend
          DECODERS.find do |name|
            begin
              self.backend = name
              true
            rescue LoadError
              # Try next decoder.
              false
            end
          end
        end
        
        private
        
        def backend_path
          'xml/backends'
        end
        
        def test_value
          <<-XML
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<oembed>
  <version>1.0</version>
  <string>test</string>
  <int>42</int>
  <html>&lt;i&gt;Cool's&lt;/i&gt;\n the &quot;word&quot;&#x21;</html>
</oembed>
          XML
        end
        
      end # self
      
    end # XML
  end
end