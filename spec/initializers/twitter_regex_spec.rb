# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'twitter_regex initializer' do
  # rubocop:enable RSpec/DescribeClass
  describe 'valid_url regex' do
    subject { Twitter::TwitterText::Regex::REGEXEN[:valid_url] }

    it 'matches URLs containing @ symbol' do
      expect(subject.match('special characters: https://gta.fandom.com/wiki/TW@ Content')[1]).to eq ' https://gta.fandom.com/wiki/TW@'
    end

    it 'matches URLs followed by @mention' do
      expect(subject.match('special characters: https://gta.fandom.com/wiki/TW @admin')[1]).to eq ' https://gta.fandom.com/wiki/TW'
    end
  end
end
