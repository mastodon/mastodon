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

    # @param [Hash] opts the options
    # @option opts [Boolean] :no_limit Do not add limit parameter
    # @option opts [String] :limit_desc custom description for limit
    # @option opts [Boolean] :no_max_id Do not add max_id parameter
    # @option opts [String] :max_id_desc custom description for max_id
    # @option opts [Boolean] :no_min_id Do not add min_id parameter
    # @option opts [String] :min_id_desc custom description for min_id
    # @option opts [Boolean] :no_since_id Do not add since_id parameter
    # @option opts [String] :since_id_desc custom description for since_id
    def rswag_page_params(opts = {})
      unless opts.fetch(:no_limit, false)
        parameter name: 'limit', in: :query, type: :integer, required: false,
                  description: opts.fetch(:limit_desc, 'Maximum number of results to return.')
      end
      unless opts.fetch(:no_max_id, false)
        parameter name: 'max_id', in: :query, required: false, type: :string,
                  description: opts.fetch(:max_id_desc, '**Internal parameter**. Use HTTP Link header for pagination.')
      end
      unless opts.fetch(:no_min_id, false)
        parameter name: 'min_id', in: :query, required: false, type: :string,
                  description: opts.fetch(:min_id_desc, '**Internal parameter**. Use HTTP Link header for pagination.')
      end
      unless opts.fetch(:no_since_id, false)
        parameter name: 'since_id', in: :query, required: false, type: :string,
                  description: opts.fetch(:since_id_desc, '**Internal parameter**. Use HTTP Link header for pagination.')
      end
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
