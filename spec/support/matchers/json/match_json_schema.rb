# frozen_string_literal: true

RSpec::Matchers.define :match_json_schema do |schema|
  match do |input_json|
    schema_path = Rails.root.join('spec', 'support', 'schema', "#{schema}.json").to_s
    JSON::Validator.validate(schema_path, input_json, validate_schema: true)
  end
end
