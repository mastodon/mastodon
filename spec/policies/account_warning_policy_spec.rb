# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountWarningPolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :show? do
    context 'with an admin' do
      it { is_expected.to permit(admin, AccountWarning.new) }
    end

    context 'with a non-admin' do
      context 'when account is not target' do
        it { is_expected.to_not permit(account, AccountWarning.new) }
      end

      context 'when account is target' do
        it { is_expected.to permit(account, AccountWarning.new(target_account_id: account.id)) }
      end
    end
  end

  permissions :appeal? do
    context 'when account is not target' do
      it { is_expected.to_not permit(account, AccountWarning.new) }
    end

    context 'when account is target' do
      context 'when record is appealable' do
        it { is_expected.to permit(account, AccountWarning.new(target_account_id: account.id, created_at: AccountWarning::APPEAL_WINDOW.ago + 1.hour)) }
      end

      context 'when record is not appealable' do
        it { is_expected.to_not permit(account, AccountWarning.new(target_account_id: account.id, created_at: AccountWarning::APPEAL_WINDOW.ago - 1.hour)) }
      end
    end
  end
end
