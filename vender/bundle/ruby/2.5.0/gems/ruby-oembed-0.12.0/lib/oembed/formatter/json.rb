module OEmbed
  module Formatter
    # Handles parsing JSON values using the best available backend.
    module JSON
      # A Array of all available backends, listed in order of preference.
      DECODERS = %w(ActiveSupportJSON JSONGem Yaml)
      
      class << self
        include ::OEmbed::Formatter::Base
        
        # Returns the current JSON backend.
        def backend
          set_default_backend unless defined?(@backend)
          raise OEmbed::FormatNotSupported, :json unless defined?(@backend)
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
          'json/backends'
        end
        
        def test_value
          <<-JSON
{"version":"1.0", "string":"test", "int":42,"html":"<i>Cool's</i>\\n the \\"word\\"\\u0021"}
          JSON
        end
        
      end # self
      
    end # JSON
  end
end