# Only allow this backend the json gem is already loaded
raise LoadError, "The json library isn't available. require 'json'" unless Object.const_defined?('JSON')

module OEmbed
  module Formatter
    module JSON
      module Backends
        module JSONGem
          extend self

          # Parses a JSON string or IO and convert it into an object.
          def decode(json)
            if json.respond_to?(:read)
              json = json.read
            end
            ::JSON.parse(json)
          end

          def decode_fail_msg
            "The version of the json library you have installed isn't parsing JSON like ruby-oembed expected."
          end

          def parse_error
            ::JSON::ParserError
          end

        end
      end
    end
  end
end
