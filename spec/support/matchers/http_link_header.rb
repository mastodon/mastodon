# frozen_string_literal: true

RSpec::Matchers.define :have_http_link_header do |rel, href|
  chain :with_type do |type|
    @type = type
  end

  match do |response|
    header_link = link_for(response, rel)

    header_link.href == href &&
      (@type.nil? || header_link.attrs['type'] == @type)
  end

  match_when_negated do |response|
    response.headers['Link'].blank?
  end

  failure_message do |response|
    (+'').tap do |string|
      string << "Expected `#{response.headers['Link']}` to include `href` value of `#{href}` "
      string << "with `type` of `#{@type}` " if @type.present?
      string << "for `rel=#{rel}` but it did not."
    end
  end

  def link_for(response, rel)
    LinkHeader
      .parse(response.headers['Link'])
      .find_link(['rel', rel.to_s])
  end
end

RSpec::Matchers.define_negated_matcher :not_have_http_link_header, :have_http_link_header # Allow chaining
