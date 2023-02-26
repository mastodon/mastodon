# frozen_string_literal: true

require 'rails_helper'

describe DeliveryStatsTracker do
  subject { described_class.new('example.com') }
  let(:current_time) { DateTime.new(2017, 1, 1, 15, 30, 12).utc }
  let(:recored_time) { current_time.beginning_of_hour }

  describe '#track_success!' do
    before do
      travel_to current_time do
        subject.track_success!
      end
    end

    it 'increments success delivery count for the host' do
      stats = subject.hourly_delivery_histories(current_time, current_time)
      expect(stats.size).to eq 1

      expected_stat = DeliveryStatsTracker::StatRecord.new(recored_time, 1, 0)
      expect(stats.first).to eq expected_stat
    end
  end

  describe '#track_failure!' do
    before do
      travel_to current_time do
        subject.track_failure!
      end
    end

    it 'increments failure delivery count for the host' do
      stats = subject.hourly_delivery_histories(current_time, current_time)
      expect(stats.size).to eq 1

      expected_stat = DeliveryStatsTracker::StatRecord.new(recored_time, 0, 1)
      expect(stats.first).to eq expected_stat
    end
  end
end
