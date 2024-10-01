# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure::ActiveUsersMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    context 'with activity tracking records' do
      before do
        3.times do
          travel_to(2.days.ago) { record_login_activity }
        end
        2.times do
          travel_to(1.day.ago) { record_login_activity }
        end
        travel_to(0.days.ago) { record_login_activity }
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

      def record_login_activity
        ActivityTracker.record('activity:logins', Fabricate(:user).id)
      end
    end
  end
end
