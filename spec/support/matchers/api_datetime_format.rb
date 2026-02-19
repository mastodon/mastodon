# frozen_string_literal: true

RSpec::Matchers.define :match_api_datetime_format do
  match(notify_expectation_failures: true) do |value|
    expect { DateTime.rfc3339(value) }
      .to_not raise_error
  end
end
