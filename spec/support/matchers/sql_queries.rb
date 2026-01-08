# frozen_string_literal: true

require 'active_record/testing/query_assertions'

# Implement something similar to Rails' built-in assertion.
# Can be removed once https://github.com/rspec/rspec-rails/pull/2818
# has been merged and released.
RSpec::Matchers.define :execute_queries do |expected = nil|
  match do |actual|
    counter = ActiveRecord::Assertions::QueryAssertions::SQLCounter.new

    queries = ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
      actual.call
      counter.log
    end

    if expected.nil?
      queries.count >= 1
    else
      queries.count == expected
    end
  end

  supports_block_expectations
end
