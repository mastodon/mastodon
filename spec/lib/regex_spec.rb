# frozen_string_literal: true

# Adopted rb/spec/extractor_spec.rb from twitter-text.
# Please contribute new changes of this file to the upstream if they are not specific to Mastodon.

# A collection of regular expressions for parsing Toot text. The regular expression
# list is frozen at load time to ensure immutability. These regular expressions are
# used throughout Mastodon. Special care has been taken to make sure these
# reular expressions work with Toots in all languages.

require 'rails_helper'
require 'text_helper'

describe 'Regex regular expressions' do
  describe 'matching URLS' do
    TestUrls::VALID.each do |url|
      it "should match the URL #{url}" do
        url.should match_autolink_expression
      end

      it "should match the URL #{url} when it's embedded in other text" do
        text = "Sweet url: #{url} I found. #awesome"
        url.should match_autolink_expression_in(text)
      end
    end
  end

  describe 'invalid URLS' do
    it 'does not link urls with invalid characters' do
      TestUrls::INVALID.each { |url| url.should_not match_autolink_expression }
    end
  end
end
