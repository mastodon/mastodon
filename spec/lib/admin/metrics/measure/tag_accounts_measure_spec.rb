# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Measure::TagAccountsMeasure do
  subject(:measure) { described_class.new(start_at, end_at, params) }

  let!(:tag) { Fabricate(:tag) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new(id: tag.id) }

  describe '#data' do
    it 'runs data query without error' do
      expect { measure.data }.to_not raise_error
    end

    context 'with tagged accounts' do
      let(:alice) { Fabricate(:account, domain: 'alice.example') }
      let(:bob) { Fabricate(:account, domain: 'bob.example') }

      before do
        3.times do
          travel_to 2.days.ago do
            tag.history.add(alice.id)
          end
        end

        2.times do
          travel_to 1.day.ago do
            tag.history.add(alice.id)
            tag.history.add(bob.id)
          end
        end

        tag.history.add(bob.id)
      end

      it 'returns correct tag_accounts counts' do
        expect(measure.data.size)
          .to eq(3)
        expect(measure.data.map(&:symbolize_keys))
          .to contain_exactly(
            include(date: 2.days.ago.midnight.to_time, value: '1'),
            include(date: 1.day.ago.midnight.to_time, value: '2'),
            include(date: 0.days.ago.midnight.to_time, value: '1')
          )
      end
    end
  end
end
