# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::Subscription do
  describe '#threshold=' do
    subject { described_class.new }

    it 'allows setting all threshold values at once' do
      subject.threshold = {
        'timeframe' => 30,
        'shares' => 5,
        'likes' => 8,
        'replies' => 7,
      }

      expect(subject.threshold_timeframe).to eq 30
      expect(subject.threshold_shares).to eq 5
      expect(subject.threshold_likes).to eq 8
      expect(subject.threshold_replies).to eq 7
    end
  end

  describe '#timeframe_start' do
    subject { described_class.new(threshold_timeframe: 45) }

    it 'returns a Time representing the beginning of the timeframe' do
      travel_to Time.zone.local(2025, 4, 7, 16, 40) do
        expect(subject.timeframe_start).to eq Time.zone.local(2025, 4, 7, 15, 55)
      end
    end
  end
end
