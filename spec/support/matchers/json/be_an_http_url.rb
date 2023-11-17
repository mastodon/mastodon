# frozen_string_literal: true

RSpec::Matchers.define :be_an_http_url do
  match do |string|
    URI::DEFAULT_PARSER.make_regexp(%w(https http)).match(string).to_s == string
  end

  failure_message do |string|
    "#{string} is not an HTTP URL."
  end
end
