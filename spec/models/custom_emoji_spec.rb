require 'rails_helper'

RSpec.describe CustomEmoji, type: :model do
  describe '#local?' do
    let(:custom_emoji) { Fabricate(:custom_emoji, domain: domain) }

    subject { custom_emoji.local? }

    context 'domain is nil' do
      let(:domain) { nil }

      it 'returns true' do
        is_expected.to be true
      end
    end

    context 'domain is present' do
      let(:domain) { 'example.com' }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#object_type' do
    it 'returns :emoji' do
      custom_emoji = Fabricate(:custom_emoji)
      expect(custom_emoji.object_type).to be :emoji
    end
  end
end
