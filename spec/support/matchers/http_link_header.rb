# frozen_string_literal: true

RSpec::Matchers.define :have_http_link_header do |href|
  match do |response|
    @response = response

    header_link&.href == href
  end

  match_when_negated do |response|
    response.headers['Link'].blank?
  end

  chain :for do |attributes|
    @attributes = attributes
  end

  failure_message do |response|
    "Expected `#{response.headers['Link']}` to include `href` value of `#{href}` for `#{@attributes}` but it did not."
  end

  failure_message_when_negated do
    "Expected response not to have a `Link` header but `#{response.headers['Link']}` is present."
  end

  def header_link
    LinkHeader
      .parse(@response.headers['Link'])
      .find_link(*@attributes.stringify_keys)
  end
end

RSpec::Matchers.define_negated_matcher :not_have_http_link_header, :have_http_link_header # Allow chaining
