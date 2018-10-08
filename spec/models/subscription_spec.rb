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

  describe 'lease_seconds' do
    it 'returns the time remaining until expiration' do
      datetime = 1.day.from_now
      subscription = Subscription.new(expires_at: datetime)
      travel_to(datetime - 12.hours) do
        expect(subscription.lease_seconds).to eq(12.hours)
      end
    end
  end

  describe 'lease_seconds=' do
    it 'sets expires_at to min expiration when small value is provided' do
      subscription = Subscription.new
      datetime = 1.day.from_now
      too_low = Subscription::MIN_EXPIRATION - 1000
      travel_to(datetime) do
        subscription.lease_seconds = too_low
      end

      expected = datetime + Subscription::MIN_EXPIRATION.seconds
      expect(subscription.expires_at).to be_within(1.0).of(expected)
    end

    it 'sets expires_at to value when valid value is provided' do
      subscription = Subscription.new
      datetime = 1.day.from_now
      valid = Subscription::MIN_EXPIRATION + 1000
      travel_to(datetime) do
        subscription.lease_seconds = valid
      end

      expected = datetime + valid.seconds
      expect(subscription.expires_at).to be_within(1.0).of(expected)
    end

    it 'sets expires_at to max expiration when large value is provided' do
      subscription = Subscription.new
      datetime = 1.day.from_now
      too_high = Subscription::MAX_EXPIRATION + 1000
      travel_to(datetime) do
        subscription.lease_seconds = too_high
      end

      expected = datetime + Subscription::MAX_EXPIRATION.seconds
      expect(subscription.expires_at).to be_within(1.0).of(expected)
    end
  end
end
