# frozen_string_literal: true

RSpec::Matchers.define :include_pagination_headers do |links|
  match do |response|
    links.map do |key, value|
      response.headers['Link'].find_link(['rel', key.to_s]).href == value
    end.all?
  end

  failure_message do |header|
    "expected that #{header} would have the same values as #{links}."
  end
end
