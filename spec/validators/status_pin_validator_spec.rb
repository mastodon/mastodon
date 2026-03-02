# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPinValidator do
  subject { Fabricate.build :status_pin }

  context 'when status is a reblog' do
    let(:status) { Fabricate.build :status, reblog: Fabricate(:status) }

    it { is_expected.to_not allow_value(status).for(:status).against(:base).with_message(I18n.t('statuses.pin_errors.reblog')) }
  end

  context 'when pin account is not status account' do
    before { subject.save }

    let(:status) { Fabricate :status, account: Fabricate(:account) }

    it { is_expected.to_not allow_value(status).for(:status).against(:base).with_message(I18n.t('statuses.pin_errors.ownership')) }
  end

  context 'when status visibility is direct' do
    let(:status) { Fabricate.build :status, visibility: :direct }

    it { is_expected.to_not allow_value(status).for(:status).against(:base).with_message(I18n.t('statuses.pin_errors.direct')) }
  end

  describe 'status pin limits' do
    before { stub_const 'StatusPinValidator::PIN_LIMIT', 2 }

    context 'when account has reached the limit' do
      before { Fabricate.times 2, :status_pin, account: }

      let(:account) { subject.account }

      it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('statuses.pin_errors.limit')) }
    end
  end
end
