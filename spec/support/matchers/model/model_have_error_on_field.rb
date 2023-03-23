# frozen_string_literal: true

RSpec::Matchers.define :model_have_error_on_field do |expected|
  match do |record|
    record.valid? if record.errors.empty?

    record.errors.key?(expected)
  end

  failure_message do |record|
    keys = record.errors.attribute_names

    "expect record.errors(#{keys}) to include #{expected}"
  end
end
