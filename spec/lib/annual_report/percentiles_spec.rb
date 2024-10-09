# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::Percentiles do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            percentiles: include(
              followers: 0,
              statuses: 0
            )
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      before do
        Fabricate.times 2, :status # Others as `account`
        Fabricate.times 2, :follow # Others as `target_account`
        Fabricate.times 2, :status, account: account
        Fabricate.times 2, :follow, target_account: account
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            percentiles: include(
              followers: 50,
              statuses: 50
            )
          )
      end
    end
  end
end
