require 'rails_helper'

RSpec.describe CustomFilter, type: :model do
  describe '#expired?' do
    it 'returns false when expiration date not set' do
      expect(described_class.new(expired_at: nil).expired?).to be false
    end

    it 'returns false when expiration date is in the future' do
      expect(described_class.new(expired_at: 20.days.from_now).expired?).to be false
    end

    it 'returns true when expiration date is past' do
      expect(described_class.new(expired_at: 1.hour.ago).expired?).to be true
    end
  end
end
