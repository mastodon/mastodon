# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::TimeSeries do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            time_series: match(
              include(followers: 0, following: 0, month: 1, statuses: 0)
            )
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      let(:month_one_date) { DateTime.new(Time.zone.now.year, 1, 1, 12, 12, 12) }

      let(:tag) { Fabricate :tag }

      before do
        _other = Fabricate :status
        Fabricate :status, account: account, created_at: month_one_date
        Fabricate :follow, account: account, created_at: month_one_date
        Fabricate :follow, target_account: account, created_at: month_one_date
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            time_series: match(
              include(followers: 1, following: 1, month: 1, statuses: 1)
            )
          )
      end
    end
  end
end
