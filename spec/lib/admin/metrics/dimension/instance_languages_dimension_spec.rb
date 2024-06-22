# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Dimension::InstanceLanguagesDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new(domain: domain) }

  describe '#data' do
    let(:domain) { 'host.example' }
    let(:alice) { Fabricate(:account, domain: domain) }
    let(:bob) { Fabricate(:account) }

    before do
      Fabricate :status, account: alice, language: 'en'
      Fabricate :status, account: bob, language: 'es'
    end

    it 'returns locales with status counts' do
      expect(subject.data.size)
        .to eq(1)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(key: 'en', value: '1')
        )
    end
  end
end
