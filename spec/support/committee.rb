# frozen_string_literal: true

require 'committee'
require 'committee/rails/test/methods'

RSpec.configure do |config|
  config.include Committee::Rails::Test::Methods
  config.add_setting :committee_options
  config.committee_options = {
    schema_path: Rails.root.join('openapi', 'openapi.json').to_s,
    query_hash_key: 'rack.request.query_hash',
    parse_response_by_content_type: true,
    strict_reference_validation: true,
  }
end
