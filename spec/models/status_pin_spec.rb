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

  describe 'Callbacks' do
    describe 'Invalidating status via policy' do
      subject { Fabricate :status_pin, status: Fabricate(:status, account: account), account: account }

      context 'with a local account that owns the status and has a policy' do
        let(:account) { Fabricate :account, domain: nil }

        before do
          Fabricate :account_statuses_cleanup_policy, account: account
          account.statuses_cleanup_policy.record_last_inspected(subject.status.id + 1_024)
        end

        it 'calls the invalidator on destroy' do
          expect { subject.destroy }
            .to change(account.statuses_cleanup_policy, :last_inspected)
        end
      end

      context 'with a local account that owns the status and does not have a policy' do
        let(:account) { Fabricate :account, domain: nil }

        it 'does not call the invalidator on destroy' do
          expect { subject.destroy }
            .to_not change(account, :updated_at)
        end
      end

      context 'with a remote account' do
        let(:account) { Fabricate :account, domain: 'host.example' }

        it 'does not call the invalidator on destroy' do
          expect { subject.destroy }
            .to_not change(account, :updated_at)
        end
      end
    end
  end
end
