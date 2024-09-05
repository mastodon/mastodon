# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPin do
  describe 'Validations' do
    subject { Fabricate.build :status_pin }

    context 'with an account pinning statuses' do
      subject { Fabricate.build :status_pin, account: account }

      let(:account) { Fabricate(:account) }

      context 'with a self-owned status' do
        let(:status) { Fabricate(:status, account: account) }

        it { is_expected.to allow_value(status).for(:status) }
      end

      context 'with a status from someone else' do
        let(:status) { Fabricate(:status) }

        it { is_expected.to_not allow_value(status).for(:status).against(:base) }
      end

      context 'with a reblog status' do
        let(:status) { Fabricate(:status, reblog: Fabricate(:status, account: account)) }

        it { is_expected.to_not allow_value(status).for(:status).against(:base) }
      end

      context 'with a private status' do
        let(:status) { Fabricate(:status, account: account, visibility: :private) }

        it { is_expected.to allow_value(status).for(:status).against(:base) }
      end

      context 'with a direct status' do
        let(:status) { Fabricate(:status, account: account, visibility: :direct) }

        it { is_expected.to_not allow_value(status).for(:status).against(:base) }
      end
    end

    context 'with a validator pin limit' do
      before { stub_const('StatusPinValidator::PIN_LIMIT', 2) }

      context 'with a local account at the limit' do
        let(:account) { Fabricate :account }

        before { Fabricate.times(StatusPinValidator::PIN_LIMIT, :status_pin, account: account) }

        it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('statuses.pin_errors.limit')) }
      end

      context 'with a remote account at the limit' do
        let(:account) { Fabricate :account, domain: 'remote.test' }

        before { Fabricate.times(StatusPinValidator::PIN_LIMIT, :status_pin, account: account) }

        it { is_expected.to allow_value(account).for(:account) }
      end
    end
  end
end
