# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure::TagServersMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let!(:tag) { Fabricate(:tag) }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }
  let(:params) { ActionController::Parameters.new(id: tag.id) }

  describe '#data' do
    context 'with tagged statuses' do
      let(:alice) { Fabricate(:account, domain: 'alice.example') }
      let(:bob) { Fabricate(:account, domain: 'bob.example') }

      before do
        3.times do
          status_alice = Fabricate(:status, account: alice, created_at: 2.days.ago)
          status_alice.tags << tag
        end

        2.times do
          status_alice = Fabricate(:status, account: alice, created_at: 1.day.ago)
          status_alice.tags << tag

          status_bob = Fabricate(:status, account: bob, created_at: 1.day.ago)
          status_bob.tags << tag
        end

        status_bob = Fabricate(:status, account: bob, created_at: 0.days.ago)
        status_bob.tags << tag
      end

      it 'returns correct tag counts' do
        expect(subject.data.size)
          .to eq(3)
        expect(subject.data.map(&:symbolize_keys))
          .to contain_exactly(
            include(date: 2.days.ago.midnight.to_time, value: '1'),
            include(date: 1.day.ago.midnight.to_time, value: '2'),
            include(date: 0.days.ago.midnight.to_time, value: '1')
          )
      end
    end
  end
end
