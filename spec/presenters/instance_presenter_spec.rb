# frozen_string_literal: true

require 'rails_helper'

describe InstancePresenter do
  before do
    one = Fabricate(:account, domain: 'example.com')
    two = Fabricate(:account, domain: 'example.com')
    Fabricate(:account, domain: 'example2.com')
    Fabricate(:account, domain: nil)
    2.times { Fabricate(:report, target_account: one) }
  end

  describe '.all' do
    it 'returns remote domains with account counts' do
      results = described_class.all

      expect(results.length).to eq(2)
      expect(results.first.domain).to eq 'example.com'
      expect(results.first.accounts_count).to eq(2)
    end
  end

  describe '#accounts_count' do
    it 'returns the count of accounts on a domain' do
      instance = described_class.new('example.com')

      expect(instance.accounts_count).to eq 2
    end
  end

  describe '#reports_count' do
    it 'returns the count of reports on a domain' do
      instance = described_class.new('example.com')

      expect(instance.reports_count).to eq 2
    end
  end

  describe '#reported_accounts_count' do
    it 'returns the count of reported accounts on a domain' do
      instance = described_class.new('example.com')

      expect(instance.reported_accounts_count).to eq 1
    end
  end
end
