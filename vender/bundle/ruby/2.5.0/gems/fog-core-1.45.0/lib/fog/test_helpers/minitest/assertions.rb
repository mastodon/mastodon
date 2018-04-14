require "fog/schema/data_validator"

module MiniTest::Assertions
  # Compares a hash's structure against a reference schema hash and returns true
  # when they match. Fog::Schema::Datavalidator is used for the validation.
  def assert_match_schema(actual, schema, message = nil, options = {})
    validator = Fog::Schema::DataValidator.new
    message = "expected:\n #{actual}\nto be equivalent of:\n#{schema}"
    assert(validator.validate(actual, schema, options), message)
  end
end
