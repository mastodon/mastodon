module RswagHelper
  module Extend
    def rswag_json_endpoint
      consumes('application/json')
      produces('application/json')
    end

    def rswag_auth_scope(scopes = ['read'])
      security [
        { bearerAuth: [] },
        { oauth: scopes }
      ]
      parameter name: :authorization, in: :header, type: :string, required: true
      rswag_json_endpoint
    end

    # Utility method, only for dev debug use
    def analyse_body_run_test!
      run_test! do |response|
        body_symbolized = rswag_parse_body_sym(response)
        body = rswag_parse_body(response)
        body_yaml = body.to_yaml
        # rubocop:disable Lint/Debugger
        binding.pry
        # rubocop:enable Lint/Debugger
      end
    end

    def rswag_add_examples!(key = nil)
      after do |example|
        example_key = key || example.metadata[:response][:description]
        example_spec = {
          "application/json"=>{
            examples: {
              example_key.to_s.parameterize.underscore || :test_example => {
                value: JSON.parse(response.body, symbolize_names: true)
              }
            }
          }
        }
        example.metadata[:response][:content] = (example.metadata[:response][:content] || {}).deep_merge(example_spec)
      end
    end
  end
end

RSpec.configure do |config|
  config.extend RswagHelper::Extend, type: :request
end
