# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Measure::NewUsersMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    context 'with user records' do
      before do
        3.times { Fabricate :user, created_at: 2.days.ago }
        2.times { Fabricate :user, created_at: 1.day.ago }
        Fabricate :user, created_at: 0.days.ago
      end

      it 'returns correct user counts' do
        expect(subject.data.size)
          .to eq(3)
        expect(subject.data.map(&:symbolize_keys))
          .to contain_exactly(
            include(date: 2.days.ago.midnight.to_time, value: '3'),
            include(date: 1.day.ago.midnight.to_time, value: '2'),
            include(date: 0.days.ago.midnight.to_time, value: '1')
          )
      end
    end
  end
end
