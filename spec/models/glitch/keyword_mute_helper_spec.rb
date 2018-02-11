require 'rails_helper'

RSpec.describe Glitch::KeywordMuteHelper do
  describe '#matches?' do
    let(:alice) { Fabricate(:account, username: 'alice').tap(&:save!) }
    let(:helper) { Glitch::KeywordMuteHelper.new(alice) }

    it 'ignores names of HTML tags in status text' do
      status = Fabricate(:status, text: '<addr>uh example</addr>')
      Glitch::KeywordMute.create!(account: alice, keyword: 'addr')

      expect(helper.matches?(status)).to be false
    end

    it 'ignores properties of HTML tags in status text' do
      status = Fabricate(:status, text: '<a href="https://www.example.org">uh example</a>')
      Glitch::KeywordMute.create!(account: alice, keyword: 'href')

      expect(helper.matches?(status)).to be false
    end

    it 'matches text inside HTML tags' do
      status = Fabricate(:status, text: '<p>HEY THIS IS SOMETHING ANNOYING</p>')
      Glitch::KeywordMute.create!(account: alice, keyword: 'annoying')

      expect(helper.matches?(status)).to be true
    end

    it 'matches < in HTML-stripped text' do
      status = Fabricate(:status, text: '<p>I <3 oats</p>')
      Glitch::KeywordMute.create!(account: alice, keyword: '<3')

      expect(helper.matches?(status)).to be true
    end

    it 'matches &lt; in HTML text' do
      status = Fabricate(:status, text: '<p>I &lt;3 oats</p>')
      Glitch::KeywordMute.create!(account: alice, keyword: '<3')

      expect(helper.matches?(status)).to be true
    end

    it 'matches link hrefs in HTML text' do
      status = Fabricate(:status, text: '<p><a href="https://example.com/it-was-milk">yep</a></p>')
      Glitch::KeywordMute.create!(account: alice, keyword: 'milk')

      expect(helper.matches?(status)).to be true
    end
  end
end
