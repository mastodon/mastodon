# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Extractor do
  describe '#extract_mentions_or_lists_with_indices' do
    it 'returns an empty array if the given string does not have at signs' do
      text = 'a string without at signs'
      extracted = described_class.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq []
    end

    it 'does not extract mentions which ends with particular characters' do
      text = '@screen_name@'
      extracted = described_class.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq []
    end

    it 'returns mentions as an array' do
      text = '@screen_name'
      extracted = described_class.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq [
        { screen_name: 'screen_name', indices: [0, 12] },
      ]
    end

    it 'yields mentions if a block is given' do
      text = '@screen_name'
      described_class.extract_mentions_or_lists_with_indices(text) do |screen_name, start_position, end_position|
        expect(screen_name).to eq 'screen_name'
        expect(start_position).to eq 0
        expect(end_position).to eq 12
      end
    end
  end

  describe '#extract_hashtags_with_indices' do
    subject { described_class.extract_hashtags_with_indices(text) }

    context 'when text does not have # or ＃' do
      let(:text) { 'a string without hash sign' }

      it { is_expected.to be_empty }
    end

    context 'when text is preceded by an ASCII hash' do
      let(:text) { 'hello #world' }

      it { is_expected.to eq [{ hashtag: 'world', indices: [6, 12] }] }
    end

    context 'when text is preceded by a full-width hash' do
      let(:text) { 'hello ＃world' }

      it { is_expected.to eq [{ hashtag: 'world', indices: [6, 12] }] }
    end

    context 'when text has normal hash text before ://' do
      let(:text) { '#hashtag://' }

      it { is_expected.to eq [{ hashtag: 'hashtag', indices: [0, 8] }] }
    end

    context 'when text is before http://' do
      let(:text) { '#hashtaghttp://' }

      it { is_expected.to eq [{ hashtag: 'hashtag', indices: [0, 8] }] }
    end

    context 'when text is before https://' do
      let(:text) { '#hashtaghttps://' }

      it { is_expected.to eq [{ hashtag: 'hashtag', indices: [0, 8] }] }
    end

    context 'when a block is given' do
      let(:text) { '#hashtag' }

      it 'extracts multiple portions' do
        subject do |hashtag, start_position, end_position|
          expect(hashtag).to eq 'hashtag'
          expect(start_position).to eq 0
          expect(end_position).to eq 8
        end
      end
    end
  end

  describe '#extract_entities_with_indices' do
    subject { described_class.extract_entities_with_indices(text) }

    context 'when cashtag is present' do
      let(:text) { '$cashtag' }

      it { is_expected.to be_empty }
    end
  end
end
