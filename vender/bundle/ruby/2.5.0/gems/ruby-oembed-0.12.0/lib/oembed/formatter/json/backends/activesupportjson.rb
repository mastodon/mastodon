# Only allow this backend if ActiveSupport::JSON is already loaded
raise LoadError, "ActiveSupport::JSON isn't available. require 'activesupport/json'" unless defined?(ActiveSupport::JSON)

module OEmbed
  module Formatter
    module JSON
      module Backends
        module ActiveSupportJSON
          extend self

          # Parses a JSON string or IO and convert it into an object.
          def decode(json)
            ::ActiveSupport::JSON.decode(json)
          end
          
          def decode_fail_msg
            "The version of ActiveSupport::JSON you have installed isn't parsing JSON like ruby-oembed expected."
          end
          
          def parse_error
            ::ActiveSupport::JSON.parse_error
          end
        
        end
      end
    end
  end
end
