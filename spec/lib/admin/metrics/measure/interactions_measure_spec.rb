# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Measure::InteractionsMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    context 'with activity tracking records' do
      before do
        3.times do
          travel_to(2.days.ago) { record_interaction_activity }
        end
        2.times do
          travel_to(1.day.ago) { record_interaction_activity }
        end
        travel_to(0.days.ago) { record_interaction_activity }
      end

      it 'returns correct activity tracker counts' do
        expect(subject.data.size)
          .to eq(3)
        expect(subject.data.map(&:symbolize_keys))
          .to contain_exactly(
            include(date: 2.days.ago.midnight.to_time, value: '3'),
            include(date: 1.day.ago.midnight.to_time, value: '2'),
            include(date: 0.days.ago.midnight.to_time, value: '1')
          )
      end

      def record_interaction_activity
        ActivityTracker.increment('activity:interactions')
      end
    end
  end
end
