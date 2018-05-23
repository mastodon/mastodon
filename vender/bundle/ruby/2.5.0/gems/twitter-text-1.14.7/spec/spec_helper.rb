$TESTING=true

# Ruby 1.8 encoding check
major, minor, patch = RUBY_VERSION.split('.')
if major.to_i == 1 && minor.to_i < 9
  $KCODE='u'
end

$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'nokogiri'
require 'json'
require 'simplecov'
SimpleCov.start do
  add_group 'Libraries', 'lib'
end

require File.expand_path('../../lib/twitter-text', __FILE__)
require File.expand_path('../test_urls', __FILE__)

RSpec.configure do |config|
  config.include TestUrls
end

RSpec::Matchers.define :match_autolink_expression do
  match do |string|
    !Twitter::Extractor.extract_urls(string).empty?
  end
end

RSpec::Matchers.define :match_autolink_expression_in do |text|
  match do |url|
    @match_data = Twitter::Regex[:valid_url].match(text)
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

RSpec::Matchers.define :link_to_screen_name do |screen_name, inner_text|
  expected = inner_text ? inner_text : screen_name

  match do |text|
    @link = Nokogiri::HTML(text).search("a.username")
    @link &&
    @link.inner_text == expected &&
    "https://twitter.com/#{screen_name}".should == @link.first['href']
  end

  failure_message_for_should do |text|
    if @link.first
      "Expected link '#{@link.inner_text}' with href '#{@link.first['href']}' to match screen_name '#{expected}', but it does not."
    else
      "Expected screen name '#{screen_name}' to be autolinked in '#{text}', but no link was found."
    end
  end

  failure_message_for_should_not do |text|
    "Expected link '#{@link.inner_text}' with href '#{@link.first['href']}' not to match screen_name '#{expected}', but it does."
  end

  description do
    "contain a link with the name and href pointing to the expected screen_name"
  end
end

RSpec::Matchers.define :link_to_list_path do |list_path, inner_text|
  expected = inner_text ? inner_text : list_path

  match do |text|
    @link = Nokogiri::HTML(text).search("a.list-slug")
    @link &&
    @link.inner_text == expected &&
    "https://twitter.com/#{list_path}".downcase.should == @link.first['href']
  end

  failure_message_for_should do |text|
    if @link.first
      "Expected link '#{@link.inner_text}' with href '#{@link.first['href']}' to match the list path '#{expected}', but it does not."
    else
      "Expected list path '#{list_path}' to be autolinked in '#{text}', but no link was found."
    end
  end

  failure_message_for_should_not do |text|
    "Expected link '#{@link.inner_text}' with href '#{@link.first['href']}' not to match the list path '#{expected}', but it does."
  end

  description do
    "contain a link with the list title and an href pointing to the list path"
  end
end

RSpec::Matchers.define :have_autolinked_hashtag do |hashtag|
  match do |text|
    @link = Nokogiri::HTML(text).search("a[@href='https://twitter.com/#!/search?q=#{hashtag.sub(/^#/, '%23')}']")
    @link &&
    @link.inner_text &&
    @link.inner_text == hashtag
  end

  failure_message_for_should do |text|
    if @link.first
      "Expected link text to be [#{hashtag}], but it was [#{@link.inner_text}] in #{text}"
    else
      "Expected hashtag #{hashtag} to be autolinked in '#{text}', but no link was found."
    end
  end

  failure_message_for_should_not do |text|
    "Expected link '#{@link.inner_text}' with href '#{@link.first['href']}' not to match the hashtag '#{hashtag}', but it does."
  end
end
