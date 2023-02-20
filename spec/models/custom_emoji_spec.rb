require 'rails_helper'

RSpec.describe CustomEmoji, type: :model do
  describe '#search' do
    subject { described_class.search(search_term) }

    let(:custom_emoji) { Fabricate(:custom_emoji, shortcode: shortcode) }

    context 'shortcode is exact' do
      let(:shortcode) { 'blobpats' }
      let(:search_term) { 'blobpats' }

      it 'finds emoji' do
        expect(subject).to include(custom_emoji)
      end
    end

    context 'shortcode is partial' do
      let(:shortcode) { 'blobpats' }
      let(:search_term) { 'blob' }

      it 'finds emoji' do
        expect(subject).to include(custom_emoji)
      end
    end
  end

  describe '#local?' do
    subject { custom_emoji.local? }

    let(:custom_emoji) { Fabricate(:custom_emoji, domain: domain) }

    context 'domain is nil' do
      let(:domain) { nil }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'domain is present' do
      let(:domain) { 'example.com' }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#object_type' do
    it 'returns :emoji' do
      custom_emoji = Fabricate(:custom_emoji)
      expect(custom_emoji.object_type).to be :emoji
    end
  end

  describe '.from_text' do
    subject { described_class.from_text(text, nil) }

    let!(:emojo) { Fabricate(:custom_emoji) }

    context 'with plain text' do
      let(:text) { 'Hello :coolcat:' }

      it 'returns records used via shortcodes in text' do
        expect(subject).to include(emojo)
      end
    end

    context 'with html' do
      let(:text) { '<p>Hello :coolcat:</p>' }

      it 'returns records used via shortcodes in text' do
        expect(subject).to include(emojo)
      end
    end
  end

  describe 'pre_validation' do
    let(:custom_emoji) { Fabricate(:custom_emoji, domain: 'wWw.MaStOdOn.CoM') }

    it 'downcases' do
      custom_emoji.valid?
      expect(custom_emoji.domain).to eq('www.mastodon.com')
    end
  end
end
