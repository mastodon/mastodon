# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure::InstanceAccountsMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:domain) { 'example.com' }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }

  let(:params) { ActionController::Parameters.new(domain: domain) }

  before do
    Fabricate(:account, domain: domain, created_at: 1.year.ago)
    Fabricate(:account, domain: domain, created_at: 1.month.ago)
    Fabricate(:account, domain: domain)

    Fabricate(:account, domain: "foo.#{domain}", created_at: 1.year.ago)
    Fabricate(:account, domain: "foo.#{domain}")
    Fabricate(:account, domain: "bar.#{domain}")
    Fabricate(:account, domain: 'other-host.example')
  end

  describe '#total' do
    context 'without include_subdomains' do
      it 'returns the expected number of accounts' do
        expect(subject.total).to eq 3
      end
    end

    context 'with include_subdomains' do
      let(:params) { ActionController::Parameters.new(domain: domain, include_subdomains: 'true') }

      it 'returns the expected number of accounts' do
        expect(subject.total).to eq 6
      end
    end
  end

  describe '#data' do
    it 'returns correct instance_accounts counts' do
      expect(subject.data.size)
        .to eq(3)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(date: 2.days.ago.midnight.to_time, value: '0'),
          include(date: 1.day.ago.midnight.to_time, value: '0'),
          include(date: 0.days.ago.midnight.to_time, value: '1')
        )
    end
  end
end
