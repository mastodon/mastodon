RSpec::Matchers.define :match_json_schema do |schema|
  match do |input_json|
    schema_directory = "#{Dir.pwd}/spec/support/schema/"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, input_json)
  end
end
