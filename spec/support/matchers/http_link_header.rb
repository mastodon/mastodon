# frozen_string_literal: true

RSpec::Matchers.define :have_http_link_header do |href, **attrs|
  match do |response|
    link_for(response, attrs)&.href == href
  end

  match_when_negated do |response|
    response.headers['Link'].blank?
  end

  failure_message do |response|
    "Expected `#{response.headers['Link']}` to include `href` value of `#{href}` for `#{attrs}` but it did not."
  end

  failure_message_when_negated do
    "Expected response not to have a `Link` header but `#{response.headers['Link']}` is present."
  end

  def link_for(response, attrs)
    LinkHeader
      .parse(response.headers['Link'])
      .find_link(*attrs.stringify_keys)
  end
end

RSpec::Matchers.define_negated_matcher :not_have_http_link_header, :have_http_link_header # Allow chaining
