require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }

  subject { Fabricate(:subscription, account: alice) }

  describe '#expired?' do
    it 'return true when expires_at is past' do
      subject.expires_at = 2.days.ago
      expect(subject.expired?).to be true
    end

    it 'return false when expires_at is future' do
      subject.expires_at = 2.days.from_now
      expect(subject.expired?).to be false
    end
  end
end
