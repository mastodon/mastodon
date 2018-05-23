module Aws
  module Plugins
    module Protocols
      class JsonRpc < Seahorse::Client::Plugin

        option(:simple_json,
          default: false,
          doc_type: 'Boolean',
          docstring: <<-DOCS)
Disables request parameter conversion, validation, and formatting.
Also disable response data type conversions. This option is useful
when you want to ensure the highest level of performance by
avoiding overhead of walking request parameters and response data
structures.

When `:simple_json` is enabled, the request parameters hash must
be formatted exactly as the DynamoDB API expects.
          DOCS

        option(:validate_params) { |config| !config.simple_json }

        option(:convert_params) { |config| !config.simple_json }

        handler(Json::Handler)

        handler(Json::ErrorHandler, step: :sign)

      end
    end
  end
end
