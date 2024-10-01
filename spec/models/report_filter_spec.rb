# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportFilter do
  describe 'with empty params' do
    it 'defaults to unresolved reports list' do
      filter = described_class.new({})

      expect(filter.results).to eq Report.unresolved
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = described_class.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end

  describe 'with valid params' do
    it 'combines filters on Report' do
      filter = described_class.new(account_id: '123', resolved: true, target_account_id: '456')

      allow(Report).to receive_messages(where: Report.none, resolved: Report.none)
      filter.results
      expect(Report).to have_received(:where).with(account_id: '123')
      expect(Report).to have_received(:where).with(target_account_id: '456')
      expect(Report).to have_received(:resolved)
    end
  end
end
