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
      6.times { |i| Redis.current.sadd('exhausted_deliveries:example.com', i) }
      subject.track_failure!

      expect(subject.days).to eq 7
      expect(described_class.available?('http://example.com/inbox')).to be false
    end

    it 'repeated calls on the same day do not count' do
      subject.track_failure!
      subject.track_failure!

      expect(subject.days).to eq 1
    end
  end

  describe '.without_unavailable' do
    before do
      Fabricate(:unavailable_domain, domain: 'foo.bar')
    end

    it 'removes URLs that are unavailable' do
      results = described_class.without_unavailable(['http://example.com/good/inbox', 'http://foo.bar/unavailable/inbox'])

      expect(results).to include('http://example.com/good/inbox')
      expect(results).to_not include('http://foo.bar/unavailable/inbox')
    end
  end

  describe '.reset!' do
    before do
      Fabricate(:unavailable_domain, domain: 'foo.bar')
      described_class.reset!('https://foo.bar/inbox')
    end

    it 'marks inbox URL as available again' do
      expect(described_class.available?('http://foo.bar/inbox')).to be true
    end
  end
end
