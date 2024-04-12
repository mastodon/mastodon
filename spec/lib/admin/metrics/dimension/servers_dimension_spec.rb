# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Dimension::ServersDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    let(:domain) { 'host.example' }
    let(:alice) { Fabricate(:account, domain: domain) }
    let(:bob) { Fabricate(:account) }

    before do
      Fabricate :status, account: alice, created_at: 1.day.ago
      Fabricate :status, account: alice, created_at: 30.days.ago
      Fabricate :status, account: bob, created_at: 1.day.ago
    end

    it 'returns domains with status counts' do
      expect(subject.data.size)
        .to eq(2)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(key: domain, value: '1'),
          include(key: Rails.configuration.x.local_domain, value: '1')
        )
    end
  end
end
