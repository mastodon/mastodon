# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Dimension::TagServersDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new(id: tag.id) }

  describe '#data' do
    let(:alice) { Fabricate(:account, domain: domain) }
    let(:bob) { Fabricate(:account) }
    let(:domain) { 'host.example' }
    let(:tag) { Fabricate(:tag) }

    before do
      alice_status_recent = Fabricate :status, account: alice, created_at: 1.day.ago
      alice_status_older = Fabricate :status, account: alice, created_at: 30.days.ago
      bob_status_recent = Fabricate :status, account: bob, created_at: 1.day.ago

      alice_status_older.tags << tag
      alice_status_recent.tags << tag
      bob_status_recent.tags << tag
    end

    it 'returns servers with tag usage counts' do
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
