# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Measure::InstanceFollowsMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:domain) { 'example.com' }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }

  let(:params) { ActionController::Parameters.new(domain: domain) }

  before do
    local_account = Fabricate(:account)

    local_account.follow!(Fabricate(:account, domain: domain))
    local_account.follow!(Fabricate(:account, domain: domain))
    Fabricate(:account, domain: domain)

    local_account.follow!(Fabricate(:account, domain: "foo.#{domain}"))
    local_account.follow!(Fabricate(:account, domain: "foo.#{domain}"))
    Fabricate(:account, domain: "bar.#{domain}")
  end

  describe '#total' do
    context 'without include_subdomains' do
      it 'returns the expected number of accounts' do
        expect(subject.total).to eq 2
      end
    end

    context 'with include_subdomains' do
      let(:params) { ActionController::Parameters.new(domain: domain, include_subdomains: 'true') }

      it 'returns the expected number of accounts' do
        expect(subject.total).to eq 4
      end
    end
  end

  describe '#data' do
    it 'returns correct instance_followers counts' do
      expect(subject.data.size)
        .to eq(3)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(date: 2.days.ago.midnight.to_time, value: '0'),
          include(date: 1.day.ago.midnight.to_time, value: '0'),
          include(date: 0.days.ago.midnight.to_time, value: '2')
        )
    end
  end
end
