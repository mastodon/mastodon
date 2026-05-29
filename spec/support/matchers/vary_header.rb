# frozen_string_literal: true

# Custom matcher for Vary header that handles Accept-Encoding being
# appended by Rack::Deflater middleware and Origin being added by
# CORS handling. Checks that all expected Vary values are present
# and only allows Accept-Encoding/Origin as additional values.
#
# Values that middleware/framework may add to Vary beyond what controllers set
ALLOWED_EXTRA_VARY_VALUES = %w[Accept-Encoding Origin].freeze

RSpec::Matchers.define :include_vary_headers do |expected|
  match do |actual|
    actual_values = actual.split(',').map(&:strip)
    expected_values = expected.split(',').map(&:strip)
    extra_values = actual_values - expected_values

    expected_values.all? { |v| actual_values.include?(v) } &&
      extra_values.all? { |v| ALLOWED_EXTRA_VARY_VALUES.include?(v) }
  end

  failure_message do |actual|
    actual_values = actual.split(',').map(&:strip)
    expected_values = expected.split(',').map(&:strip)
    extra_values = actual_values - expected_values
    unexpected = extra_values.reject { |v| ALLOWED_EXTRA_VARY_VALUES.include?(v) }

    if unexpected.any?
      "expected Vary header \"#{actual}\" to only contain #{expected_values.inspect} (plus optional Accept-Encoding/Origin), but found unexpected values: #{unexpected.inspect}"
    else
      "expected Vary header \"#{actual}\" to include all of \"#{expected}\""
    end
  end
end
