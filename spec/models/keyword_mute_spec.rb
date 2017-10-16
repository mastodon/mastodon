require 'rails_helper'

RSpec.describe KeywordMute, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice').tap(&:save!) }
  let(:bob) { Fabricate(:account, username: 'bob').tap(&:save!) }

  describe '.matcher_for' do
    let(:matcher) { KeywordMute.matcher_for(alice) }

    describe 'with no KeywordMutes for an account' do
      before do
        KeywordMute.delete_all
      end

      it 'does not match' do
        expect(matcher =~ 'This is a hot take').to be_falsy
      end
    end

    describe 'with KeywordMutes for an account' do
      it 'does not match keywords set by a different account' do
        KeywordMute.create!(account: bob, keyword: 'take')

        expect(matcher =~ 'This is a hot take').to be_falsy
      end

      it 'does not match if no keywords match the status text' do
        KeywordMute.create!(account: alice, keyword: 'cold')

        expect(matcher =~ 'This is a hot take').to be_falsy
      end

      it 'considers word boundaries when matching' do
        KeywordMute.create!(account: alice, keyword: 'bob', whole_word: true)

        expect(matcher =~ 'bobcats').to be_falsy
      end

      it 'matches substrings if whole_word is false' do
        KeywordMute.create!(account: alice, keyword: 'take', whole_word: false)

        expect(matcher =~ 'This is a shiitake mushroom').to be_truthy
      end

      it 'matches keywords at the beginning of the text' do
        KeywordMute.create!(account: alice, keyword: 'take')

        expect(matcher =~ 'Take this').to be_truthy
      end

      it 'matches keywords at the beginning of the text' do
        KeywordMute.create!(account: alice, keyword: 'take')

        expect(matcher =~ 'This is a hot take').to be_truthy
      end

      it 'matches if at least one keyword case-insensitively matches the text' do
        KeywordMute.create!(account: alice, keyword: 'hot')

        expect(matcher =~ 'This is a HOT take').to be_truthy
      end

      it 'matches keywords surrounded by non-alphanumeric ornamentation' do
        KeywordMute.create!(account: alice, keyword: 'hot')

        expect(matcher =~ 'This is a ~*HOT*~ take').to be_truthy
      end

      it 'uses case-folding rules appropriate for more than just English' do
        KeywordMute.create!(account: alice, keyword: 'großeltern')

        expect(matcher =~ 'besuch der grosseltern').to be_truthy
      end

      it 'matches keywords that are composed of multiple words' do
        KeywordMute.create!(account: alice, keyword: 'a shiitake')

        expect(matcher =~ 'This is a shiitake').to be_truthy
        expect(matcher =~ 'This is shiitake').to_not be_truthy
      end
    end
  end
end
