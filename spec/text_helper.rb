# frozen_string_literal: true

# Adopted rb/spec/spec_helper.rb from twitter-text.
# Please contribute new changes of this file to the upstream if they are not specific to Mastodon.

require 'nokogiri'
require 'json'
require 'test_urls'

RSpec.configure do |config|
  config.include TestUrls
end

RSpec::Matchers.define :match_autolink_expression do
  match do |string|
    !Extractor.extract_urls(string).empty?
  end
end

RSpec::Matchers.define :match_autolink_expression_in do |text|
  match do |url|
    @match_data = Regex[:valid_url].match(text)
    @match_data && @match_data.to_s.strip == url
  end

  failure_message_for_should do |url|
    "Expected to find url '#{url}' in text '#{text}', but the match was #{@match_data.captures}'"
  end
end

RSpec::Matchers.define :have_autolinked_url do |url, inner_text|
  match do |text|
    @link = Nokogiri::HTML(text).search("a[@href='#{url}']")
    @link &&
      @link.inner_text &&
      (inner_text && @link.inner_text == inner_text) || (!inner_text && @link.inner_text == url)
  end

  failure_message_for_should do |text|
    "Expected url '#{url}'#{", inner_text '#{inner_text}'" if inner_text} to be autolinked in '#{text}'"
  end
end
