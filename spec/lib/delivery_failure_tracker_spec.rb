# frozen_string_literal: true

require 'rails_helper'

describe DeliveryFailureTracker do
  subject { described_class.new('http://example.com/inbox') }

  describe '#track_success!' do
    before do
      subject.track_failure!
      subject.track_success!
    end

    it 'marks URL as available again' do
      expect(described_class.available?('http://example.com/inbox')).to be true
    end

    it 'resets days to 0' do
      expect(subject.days).to be_zero
    end
  end

  describe '#track_failure!' do
    it 'marks URL as unavailable after 7 days of being called' do
      6.times { |i| Redis.current.sadd('exhausted_deliveries:http://example.com/inbox', i) }
      subject.track_failure!

      expect(subject.days).to eq 7
      expect(described_class.unavailable?('http://example.com/inbox')).to be true
    end

    it 'repeated calls on the same day do not count' do
      subject.track_failure!
      subject.track_failure!

      expect(subject.days).to eq 1
    end
  end

  describe '.filter' do
    before do
      Redis.current.sadd('unavailable_inboxes', 'http://example.com/unavailable/inbox')
    end

    it 'removes URLs that are unavailable' do
      result = described_class.filter(['http://example.com/good/inbox', 'http://example.com/unavailable/inbox'])

      expect(result).to include('http://example.com/good/inbox')
      expect(result).to_not include('http://example.com/unavailable/inbox')
    end
  end

  describe '.track_inverse_success!' do
    let(:from_account) { Fabricate(:account, inbox_url: 'http://example.com/inbox', shared_inbox_url: 'http://example.com/shared/inbox') }

    before do
      Redis.current.sadd('unavailable_inboxes', 'http://example.com/inbox')
      Redis.current.sadd('unavailable_inboxes', 'http://example.com/shared/inbox')

      described_class.track_inverse_success!(from_account)
    end

    it 'marks inbox URL as available again' do
      expect(described_class.available?('http://example.com/inbox')).to be true
    end

    it 'marks shared inbox URL as available again' do
      expect(described_class.available?('http://example.com/shared/inbox')).to be true
    end
  end
end
