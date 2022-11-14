# frozen_string_literal: true

require 'yaml'
require 'rails_helper'

swagger_root = Rails.root.join('api-docs').to_s
v1_base_definition = YAML.load_file(Rails.root.join(swagger_root, 'base_definition.yml'))


RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = swagger_root

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'schema.yml' => {
      openapi: v1_base_definition.fetch('openapi', '3.0.1'),
      info: v1_base_definition.fetch('info', {
        title: 'API',
        version: '0.0.1'
      }),
      servers: v1_base_definition.fetch('servers', [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ]),
      security: v1_base_definition.fetch('security', []),
      components: v1_base_definition.fetch('components', {}),
      paths: {},
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
