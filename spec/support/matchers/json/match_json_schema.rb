# frozen_string_literal: true

RSpec::Matchers.define :match_json_schema do |schema|
  match do |input_json|
    schema_path = Rails.root.join('spec', 'support', 'schema', "#{schema}.json").to_s
    JSON::Validator.validate(schema_path, input_json, validate_schema: true)
  end
end

RSpec::Matchers.define :match_json_values do |values|
  match do |string|
    expect(json_str_to_hash(string))
      .to include(values)
  end

  failure_message do |value|
    "expected that #{value} would have the same values as #{values}."
  end
end
