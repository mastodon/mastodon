# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Measure::InstanceStatusesMeasure do
  subject(:measure) { described_class.new(start_at, end_at, params) }

  let(:domain) { 'example.com' }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }

  let(:params) { ActionController::Parameters.new(domain: domain) }

  before do
    Fabricate(:status, account: Fabricate(:account, domain: domain))
    Fabricate(:status, account: Fabricate(:account, domain: domain))

    Fabricate(:status, account: Fabricate(:account, domain: "foo.#{domain}"))
    Fabricate(:status, account: Fabricate(:account, domain: "foo.#{domain}"))
    Fabricate(:status, account: Fabricate(:account, domain: "bar.#{domain}"))
  end

  describe 'total' do
    context 'without include_subdomains' do
      it 'returns the expected number of accounts' do
        expect(measure.total).to eq 2
      end
    end

    context 'with include_subdomains' do
      let(:params) { ActionController::Parameters.new(domain: domain, include_subdomains: 'true') }

      it 'returns the expected number of accounts' do
        expect(measure.total).to eq 5
      end
    end
  end

  describe '#data' do
    it 'runs data query without error' do
      expect { measure.data }.to_not raise_error
    end
  end
end
