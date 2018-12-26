RSpec::Matchers.define :model_have_error_on_field do |expected|
  match do |record|
    if record.errors.empty?
      record.valid?
    end

    record.errors.has_key?(expected)
  end

  failure_message do |record|
    keys = record.errors.keys

    "expect record.errors(#{keys}) to include #{expected}"
  end
end
