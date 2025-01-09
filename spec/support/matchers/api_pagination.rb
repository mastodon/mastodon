# frozen_string_literal: true

RSpec::Matchers.define :include_pagination_headers do |links|
  match do |response|
    links.map do |key, value|
      expect(response).to have_http_link_header(value).for(rel: key.to_s)
    end.all?
  end

  failure_message do |response|
    "expected that #{response.headers['Link']} would have the same values as #{links}."
  end
end
