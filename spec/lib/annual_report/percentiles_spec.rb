# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::Percentiles do
  describe '#generate' do
    subject { described_class.new(account, year) }

    let(:year) { Time.zone.now.year }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        described_class.prepare(year)

        expect(subject.generate)
          .to include(
            percentiles: include(
              statuses: 100
            )
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      before do
        Fabricate.times 2, :status # Others as `account`
        Fabricate.times 2, :status, account: account
      end

      it 'builds a report for an account' do
        described_class.prepare(year)

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
