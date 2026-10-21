# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Extractor do
  describe '#extract_mentions_or_lists_with_indices' do
    subject { described_class.extract_mentions_or_lists_with_indices(text) }

    context 'when text does not have at signs' do
      let(:text) { 'a string without at signs' }

      it { is_expected.to be_empty }
    end

    context 'when text ends with matching character' do
      let(:text) { '@screen_name@' }

      it { is_expected.to be_empty }
    end

    context 'when text includes a mentioned username' do
      let(:text) { '@screen_name' }

      it { is_expected.to contain_exactly({ screen_name: 'screen_name', indices: [0, 12] }) }
    end

    context 'when a block is given' do
      let(:text) { '@screen_name' }

      it 'extracts multiple portions' do
        expect { |probe| described_class.extract_mentions_or_lists_with_indices(text, &probe) }
          .to yield_with_args('screen_name', 0, 12)
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
        expect { |probe| described_class.extract_hashtags_with_indices(text, &probe) }
          .to yield_with_args('hashtag', 0, 8)
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
