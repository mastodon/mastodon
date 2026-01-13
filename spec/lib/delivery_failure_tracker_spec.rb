# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeliveryFailureTracker do
  context 'with the default resolution of :days' do
    subject { described_class.new('http://example.com/inbox') }

    describe '#track_success!' do
      before do
        track_failure(7, :days)
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
        track_failure(7, :days)

        expect(subject.days).to eq 7
        expect(described_class.available?('http://example.com/inbox')).to be false
      end

      it 'repeated calls on the same day do not count' do
        subject.track_failure!
        subject.track_failure!

        expect(subject.days).to eq 1
      end
    end

    describe '#exhausted_deliveries_days' do
      it 'returns the days on which failures were recorded' do
        track_failure(3, :days)

        expect(subject.exhausted_deliveries_days).to contain_exactly(3.days.ago.to_date, 2.days.ago.to_date, Date.yesterday)
      end
    end
  end

  context 'with a resolution of :minutes' do
    subject { described_class.new('http://example.com/inbox', resolution: :minutes) }

    describe '#track_success!' do
      before do
        track_failure(5, :minutes)
        subject.track_success!
      end

      it 'marks URL as available again' do
        expect(described_class.available?('http://example.com/inbox')).to be true
      end

      it 'resets failures to 0' do
        expect(subject.failures).to be_zero
      end
    end

    describe '#track_failure!' do
      it 'marks URL as unavailable after 5 minutes of being called' do
        track_failure(5, :minutes)

        expect(subject.failures).to eq 5
        expect(described_class.available?('http://example.com/inbox')).to be false
      end

      it 'repeated calls within the same minute do not count' do
        freeze_time
        subject.track_failure!
        subject.track_failure!

        expect(subject.failures).to eq 1
      end
    end

    describe '#exhausted_deliveries_days' do
      it 'returns the days on which failures were recorded' do
        # Make sure this does not accidentally span two days when run
        # around midnight
        travel_to Time.zone.now.change(hour: 10)
        track_failure(3, :minutes)

        expect(subject.exhausted_deliveries_days).to contain_exactly(Time.zone.today)
      end
    end

    describe '#days' do
      it 'raises due to wrong resolution' do
        assert_raises TypeError do
          subject.days
        end
      end
    end
  end

  describe '.without_unavailable' do
    before do
      Fabricate(:unavailable_domain, domain: 'foo.bar')
    end

    it 'removes URLs that are bogus or unavailable' do
      results = described_class.without_unavailable(['http://example.com/good/inbox', 'http://foo.bar/unavailable/inbox', '{foo:'])

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

  def track_failure(times, unit)
    times.times do
      travel_to 1.send(unit).ago
      subject.track_failure!
    end
    travel_back
  end
end
