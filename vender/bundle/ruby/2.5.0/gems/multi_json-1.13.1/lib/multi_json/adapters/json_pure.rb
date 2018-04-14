require 'json/pure'
require 'multi_json/adapters/json_common'

module MultiJson
  module Adapters
    # Use JSON pure to dump/load.
    class JsonPure < JsonCommon
      ParseError = ::JSON::ParserError
    end
  end
end
