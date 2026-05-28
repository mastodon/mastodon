# frozen_string_literal: true

# Custom matcher for Vary header that handles Accept-Encoding being
# appended by Rack::Deflater middleware. Checks that all expected
# Vary values are present and only allows Accept-Encoding as an
# additional value beyond what's expected.
RSpec::Matchers.define :include_vary_headers do |expected|
  match do |actual|
    actual_values = actual.split(',').map(&:strip)
    expected_values = expected.split(',').map(&:strip)
    extra_values = actual_values - expected_values

    expected_values.all? { |v| actual_values.include?(v) } &&
      extra_values.all? { |v| v == 'Accept-Encoding' }
  end

  failure_message do |actual|
    actual_values = actual.split(',').map(&:strip)
    expected_values = expected.split(',').map(&:strip)
    extra_values = actual_values - expected_values
    unexpected = extra_values.reject { |v| v == 'Accept-Encoding' }

    if unexpected.any?
      "expected Vary header \"#{actual}\" to only contain #{expected_values.inspect} (plus optional Accept-Encoding), but found unexpected values: #{unexpected.inspect}"
    else
      "expected Vary header \"#{actual}\" to include all of \"#{expected}\""
    end
  end
end
