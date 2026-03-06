# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::Redirect do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:acct) }

    describe 'target account validation' do
      subject { described_class.new(account:) }

      context 'when target_account is missing' do
        let(:account) { Fabricate.build :account }

        it { is_expected.to_not allow_value(nil).for(:target_account).against(:acct).with_message(I18n.t('migrations.errors.not_found')) }
      end

      context 'when account already moved' do
        let(:account) { Fabricate.build :account, moved_to_account_id: target_account.id }
        let(:target_account) { Fabricate :account }

        it { is_expected.to_not allow_value(target_account).for(:target_account).against(:acct).with_message(I18n.t('migrations.errors.already_moved')) }
      end

      context 'when moving to self' do
        let(:account) { Fabricate :account }

        it { is_expected.to_not allow_value(account).for(:target_account).against(:acct).with_message(I18n.t('migrations.errors.move_to_self')) }
      end
    end
  end
end
