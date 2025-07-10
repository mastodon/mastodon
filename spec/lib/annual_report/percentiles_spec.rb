# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::Percentiles do
  describe '#generate' do
    subject { described_class.new(account, year) }

    let(:year) { Time.zone.now.year }
    let(:account) { Fabricate :account }

    context 'with no status data' do
      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            percentiles: include(
              statuses: 100
            )
          )
      end
    end

    context 'with status count data' do
      before do
        # Simulate scenario where other accounts have each made one status
        Fabricate.times 2, :annual_report_statuses_per_account_count, statuses_count: 1

        Fabricate.times 2, :status, account: account
        Fabricate :annual_report_statuses_per_account_count, account_id: account.id, statuses_count: 2
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            percentiles: include(
              statuses: 50
            )
          )
      end
    end
  end
end
