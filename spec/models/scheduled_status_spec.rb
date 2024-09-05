# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduledStatus do
  let(:account) { Fabricate(:account) }

  describe 'Validations' do
    subject { Fabricate.build :scheduled_status }

    context 'when scheduled_at is less than minimum offset' do
      it { is_expected.to_not allow_value(4.minutes.from_now).for(:scheduled_at).with_message(I18n.t('scheduled_statuses.too_soon')) }
    end

    context 'when account has reached total limit' do
      before do
        stub_const('ScheduledStatus::TOTAL_LIMIT', 0)
      end

      it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('scheduled_statuses.over_total_limit', limit: ScheduledStatus::TOTAL_LIMIT)) }
    end

    context 'when account has reached daily limit' do
      subject { Fabricate.build(:scheduled_status, scheduled_at: base_time + 10.minutes) }

      let(:base_time) { Time.current.change(hour: 12) }

      before do
        stub_const('ScheduledStatus::DAILY_LIMIT', 3)

        travel_to base_time do
          Fabricate.times(ScheduledStatus::DAILY_LIMIT, :scheduled_status, account: account, scheduled_at: base_time + 1.hour)
        end
      end

      it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('scheduled_statuses.over_daily_limit', limit: ScheduledStatus::DAILY_LIMIT)) }
    end
  end
end
