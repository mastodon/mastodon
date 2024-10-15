# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status#emojis extension for emoji reaction' do # rubocop:disable RSpec/DescribeClass
  describe 'regression check' do
    subject { Fabricate(:status, account: alice, text: text) }

    let(:alice) { Fabricate(:account, username: 'alice', domain: 'fuga.com') }
    let(:emoji) { Fabricate(:custom_emoji, shortcode: 'hoge', domain: 'fuga.com') }

    before do
      alice
      emoji
    end

    context 'with emoji' do
      let(:text) { 'some text with :hoge:' }

      it 'returns emojis' do
        expect(subject.emojis).to eq [emoji]
      end
    end

    context 'without emoji' do
      let(:text) { 'some text without emoji' }

      it 'returns []' do
        expect(subject.emojis).to eq []
      end
    end
  end

  describe 'emoji reaction' do
    subject { Fabricate(:status, account: alice, text: text) }

    let!(:alice) { Fabricate(:account, username: 'alice', domain: 'alice.com') }
    let!(:bob) { Fabricate(:account, username: 'bob', domain: 'bob.com') }
    let!(:emoji_alice) { Fabricate(:custom_emoji, shortcode: 'emoji_alice', domain: 'alice.com') }
    let!(:emoji_bob) { Fabricate(:custom_emoji, shortcode: 'emoji_bob', domain: 'bob.com') }

    context 'with custom emoji both in text and reaction' do
      let(:text) { 'some text with :emoji_alice:' }

      before do
        Fabricate(:favourite, account: bob, status: subject, emoji: ':emoji_bob:', custom_emoji: emoji_bob)
      end

      it 'returns both emojis' do
        expect(subject.emojis.sort_by(&:id)).to eq [emoji_alice, emoji_bob].sort_by(&:id)
      end
    end

    context 'with custom emoji in reaction but not in text' do
      let(:text) { 'some text without emoji' }

      before do
        Fabricate(:favourite, account: bob, status: subject, emoji: ':emoji_bob:', custom_emoji: emoji_bob)
      end

      it 'returns emojis in reaction' do
        expect(subject.emojis).to eq [emoji_bob]
      end
    end

    context 'with favourite without reaction' do
      let(:text) { 'some text without emoji' }

      before do
        Fabricate(:favourite, account: bob, status: subject)
      end

      it 'returns []' do
        expect(subject.emojis).to eq []
      end
    end

    context 'with favourite without reaction and favourite with reaction' do
      let(:text) { 'some text without emoji' }

      before do
        Fabricate(:favourite, account: bob, status: subject)
        Fabricate(:favourite, account: alice, status: subject, emoji: ':emoji_alice:', custom_emoji: emoji_alice)
      end

      it 'returns favourite with reaction' do
        expect(subject.emojis).to eq [emoji_alice]
      end
    end
  end
end
