require 'rails_helper'

describe ReportFilter do
  describe 'with empty params' do
    it 'defaults to unresolved reports list' do
      filter = ReportFilter.new({})

      expect(filter.results).to eq Report.unresolved
    end
  end

  describe 'with invalid params' do
    it 'raises with key error' do
      filter = ReportFilter.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end
  end

  describe 'with valid params' do
    it 'combines filters on Report' do
      filter = ReportFilter.new(account_id: '123', resolved: true)

      allow(Report).to receive(:where).and_return(Report.none)
      allow(Report).to receive(:resolved).and_return(Report.none)
      filter.results
      expect(Report).to have_received(:where).with(account_id: '123')
      expect(Report).to have_received(:resolved)
    end
  end
end
