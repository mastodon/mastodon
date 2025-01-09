# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure::TagAccountsMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let!(:tag) { Fabricate(:tag) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new(id: tag.id) }

  describe '#data' do
    context 'with tagged accounts' do
      let(:alice) { Fabricate(:account, domain: 'alice.example') }
      let(:bob) { Fabricate(:account, domain: 'bob.example') }

      before do
        3.times do
          travel_to(2.days.ago) { add_tag_history(alice) }
        end

        2.times do
          travel_to(1.day.ago) do
            add_tag_history(alice)
            add_tag_history(bob)
          end
        end

        add_tag_history(bob)
      end

      it 'returns correct tag_accounts counts' do
        expect(subject.data.size)
          .to eq(3)
        expect(subject.data.map(&:symbolize_keys))
          .to contain_exactly(
            include(date: 2.days.ago.midnight.to_time, value: '1'),
            include(date: 1.day.ago.midnight.to_time, value: '2'),
            include(date: 0.days.ago.midnight.to_time, value: '1')
          )
      end

      def add_tag_history(account)
        tag.history.add(account.id)
      end
    end
  end
end
