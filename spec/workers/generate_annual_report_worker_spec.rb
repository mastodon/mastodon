# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateAnnualReportWorker do
  let(:worker) { described_class.new }
  let(:account) { Fabricate :account }

  describe '#perform' do
    it 'generates new report for the account' do
      expect { worker.perform(account.id, Date.current.year) }
        .to change(account_reports, :count).by(1)
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123, Date.current.year)

      expect(result).to be(true)
    end

    def account_reports
      GeneratedAnnualReport
        .where(account: account)
        .where(year: Date.current.year)
    end
  end
end
