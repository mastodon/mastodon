# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntityCache do
  let(:local_account)  { Fabricate(:account, domain: nil, username: 'alice') }
  let(:remote_account) { Fabricate(:account, domain: 'remote.test', username: 'bob', url: 'https://remote.test/') }

  describe '#emoji' do
    subject { described_class.instance.emoji(shortcodes, domain) }

    context 'when called with an empty list of shortcodes' do
      let(:shortcodes) { [] }
      let(:domain)     { 'example.org' }

      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end

    context 'when called with emoji shortcodes that differ only by case' do
      let!(:emoji_lower) { Fabricate(:custom_emoji, shortcode: 'blobhaj_mlem', domain: 'example.org') }
      let!(:emoji_mixed) { Fabricate(:custom_emoji, shortcode: 'Blobhaj_Mlem', domain: 'example.org') }
      let(:shortcodes) { ['blobhaj_mlem', 'Blobhaj_Mlem'] }
      let(:domain) { 'example.org' }

      it 'returns both emoji objects' do
        result = subject
        expect(result).to contain_exactly(emoji_lower, emoji_mixed)
      end

      it 'generates different cache keys for different cases' do
        cache_key_lower = described_class.instance.to_key(:emoji, 'blobhaj_mlem', 'example.org')
        cache_key_mixed = described_class.instance.to_key(:emoji, 'Blobhaj_Mlem', 'example.org')

        expect(cache_key_lower).to eq('emoji:blobhaj_mlem:example.org')
        expect(cache_key_mixed).to eq('emoji:Blobhaj_Mlem:example.org')
        expect(cache_key_lower).not_to eq(cache_key_mixed)
      end
    end
  end

  describe '#to_key' do
    subject { described_class.instance }

    it 'preserves case for emoji cache keys' do
      key = subject.to_key(:emoji, 'TestEmoji', 'Example.Com')
      expect(key).to eq('emoji:TestEmoji:Example.Com')
    end

    it 'preserves case for emoji cache keys with nil domain' do
      key = subject.to_key(:emoji, 'TestEmoji', nil)
      expect(key).to eq('emoji:TestEmoji')
    end

    it 'maintains case-insensitive behavior for status cache keys' do
      key = subject.to_key(:status, 'https://Example.Com/Test')
      expect(key).to eq('status:https://example.com/test')
    end

    it 'maintains case-insensitive behavior for mention cache keys' do
      key = subject.to_key(:mention, 'TestUser', 'Example.Com')
      expect(key).to eq('mention:testuser:example.com')
    end

    it 'handles multiple ids correctly for emoji' do
      key = subject.to_key(:emoji, 'FirstEmoji', 'SecondEmoji', 'domain.com')
      expect(key).to eq('emoji:FirstEmoji:SecondEmoji:domain.com')
    end

    it 'filters out nil values' do
      key = subject.to_key(:emoji, 'TestEmoji', nil, 'domain.com')
      expect(key).to eq('emoji:TestEmoji:domain.com')
    end
  end
end
