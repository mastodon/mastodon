# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduledStatus do
  let(:account) { Fabricate(:account) }

  describe 'validations' do
    context 'when scheduled_at is less than minimum offset' do
      subject { Fabricate.build(:scheduled_status, scheduled_at: 4.minutes.from_now, account: account) }

      it 'is not valid', :aggregate_failures do
        expect(subject).to_not be_valid
        expect(subject.errors[:scheduled_at]).to include(I18n.t('scheduled_statuses.too_soon'))
      end
    end

    context 'when account has reached total limit' do
      subject { Fabricate.build(:scheduled_status, account: account) }

      before do
        allow(account.scheduled_statuses).to receive(:count).and_return(described_class::TOTAL_LIMIT)
      end

      it 'is not valid', :aggregate_failures do
        expect(subject).to_not be_valid
        expect(subject.errors[:base]).to include(I18n.t('scheduled_statuses.over_total_limit', limit: ScheduledStatus::TOTAL_LIMIT))
      end
    end

    context 'when account has reached daily limit' do
      subject { Fabricate.build(:scheduled_status, account: account, scheduled_at: base_time + 10.minutes) }

      let(:base_time) { Time.current.change(hour: 12) }

      before do
        stub_const('ScheduledStatus::DAILY_LIMIT', 3)

        travel_to base_time do
          Fabricate.times(ScheduledStatus::DAILY_LIMIT, :scheduled_status, account: account, scheduled_at: base_time + 1.hour)
        end
      end

      it 'is not valid', :aggregate_failures do
        expect(subject).to_not be_valid
        expect(subject.errors[:base]).to include(I18n.t('scheduled_statuses.over_daily_limit', limit: ScheduledStatus::DAILY_LIMIT))
      end
    end
  end
end
