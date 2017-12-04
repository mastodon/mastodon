require 'rails_helper'

RSpec.describe Glitch::KeywordMute, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice').tap(&:save!) }
  let(:bob) { Fabricate(:account, username: 'bob').tap(&:save!) }

  describe '.text_matcher_for' do
    let(:matcher) { Glitch::KeywordMute.text_matcher_for(alice.id) }

    describe 'with no mutes' do
      before do
        Glitch::KeywordMute.delete_all
      end

      it 'does not match' do
        expect(matcher.matches?('This is a hot take')).to be_falsy
      end
    end

    describe 'with mutes' do
      it 'does not match keywords set by a different account' do
        Glitch::KeywordMute.create!(account: bob, keyword: 'take')

        expect(matcher.matches?('This is a hot take')).to be_falsy
      end

      it 'does not match if no keywords match the status text' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'cold')

        expect(matcher.matches?('This is a hot take')).to be_falsy
      end

      it 'considers word boundaries when matching' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'bob', whole_word: true)

        expect(matcher.matches?('bobcats')).to be_falsy
      end

      it 'matches substrings if whole_word is false' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'take', whole_word: false)

        expect(matcher.matches?('This is a shiitake mushroom')).to be_truthy
      end

      it 'matches keywords at the beginning of the text' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'take')

        expect(matcher.matches?('Take this')).to be_truthy
      end

      it 'matches keywords at the end of the text' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'take')

        expect(matcher.matches?('This is a hot take')).to be_truthy
      end

      it 'matches if at least one keyword case-insensitively matches the text' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'hot')

        expect(matcher.matches?('This is a HOT take')).to be_truthy
      end

      it 'maintains case-insensitivity when combining keywords into a single matcher' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'hot')
        Glitch::KeywordMute.create!(account: alice, keyword: 'cold')

        expect(matcher.matches?('This is a HOT take')).to be_truthy
      end

      it 'matches keywords surrounded by non-alphanumeric ornamentation' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'hot')

        expect(matcher.matches?('(hot take)')).to be_truthy
      end

      it 'escapes metacharacters in keywords' do
        Glitch::KeywordMute.create!(account: alice, keyword: '(hot take)')

        expect(matcher.matches?('(hot take)')).to be_truthy
      end

      it 'uses case-folding rules appropriate for more than just English' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'großeltern')

        expect(matcher.matches?('besuch der grosseltern')).to be_truthy
      end

      it 'matches keywords that are composed of multiple words' do
        Glitch::KeywordMute.create!(account: alice, keyword: 'a shiitake')

        expect(matcher.matches?('This is a shiitake')).to be_truthy
        expect(matcher.matches?('This is shiitake')).to_not be_truthy
      end
    end
  end

  describe '.tag_matcher_for' do
    let(:matcher) { Glitch::KeywordMute.tag_matcher_for(alice.id) }
    let(:status) { Fabricate(:status) }

    describe 'with no mutes' do
      before do
        Glitch::KeywordMute.delete_all
      end

      it 'does not match' do
        status.tags << Fabricate(:tag, name: 'xyzzy')

        expect(matcher.matches?(status.tags)).to be false
      end
    end

    describe 'with mutes' do
      it 'does not match keywords set by a different account' do
        status.tags << Fabricate(:tag, name: 'xyzzy')
        Glitch::KeywordMute.create!(account: bob, keyword: 'take')

        expect(matcher.matches?(status.tags)).to be false
      end

      it 'matches #xyzzy when given the mute "#xyzzy"' do
        status.tags << Fabricate(:tag, name: 'xyzzy')
        Glitch::KeywordMute.create!(account: alice, keyword: '#xyzzy')

        expect(matcher.matches?(status.tags)).to be true
      end

      it 'matches #thingiverse when given the non-whole-word mute "#thing"' do
        status.tags << Fabricate(:tag, name: 'thingiverse')
        Glitch::KeywordMute.create!(account: alice, keyword: '#thing', whole_word: false)

        expect(matcher.matches?(status.tags)).to be true
      end

      it 'matches #hashtag when given the mute "##hashtag""' do
        status.tags << Fabricate(:tag, name: 'hashtag')
        Glitch::KeywordMute.create!(account: alice, keyword: '##hashtag')

        expect(matcher.matches?(status.tags)).to be true
      end

      it 'matches #oatmeal when given the non-whole-word mute "oat"' do
        status.tags << Fabricate(:tag, name: 'oatmeal')
        Glitch::KeywordMute.create!(account: alice, keyword: 'oat', whole_word: false)

        expect(matcher.matches?(status.tags)).to be true
      end

      it 'does not match #oatmeal when given the mute "#oat"' do
        status.tags << Fabricate(:tag, name: 'oatmeal')
        Glitch::KeywordMute.create!(account: alice, keyword: 'oat')

        expect(matcher.matches?(status.tags)).to be false
      end
    end
  end
end
