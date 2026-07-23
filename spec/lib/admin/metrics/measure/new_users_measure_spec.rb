# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure::NewUsersMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    context 'with user records' do
      before do
        travel_to 2.days.ago do
          # We specify the `id` because `travel_to` doesn't affect the database
          3.times { Fabricate :account, id: Mastodon::Snowflake.id_at(Time.now.utc) }
        end

        travel_to 1.day.ago do
          # We specify the `id` because `travel_to` doesn't affect the database
          2.times { Fabricate :account, id: Mastodon::Snowflake.id_at(Time.now.utc) }
        end

        Fabricate :user
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
