# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountPin do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:target_account).required }
  end

  describe 'Validations' do
    describe 'the follow relationship' do
      subject { Fabricate.build :account_pin, account: account }

      let(:account) { Fabricate :account }
      let(:target_account) { Fabricate :account }

      context 'when account is following target account' do
        before { account.follow!(target_account) }

        it { is_expected.to allow_value(target_account).for(:target_account).against(:base) }
      end

      context 'when account is not following target account' do
        it { is_expected.to_not allow_value(target_account).for(:target_account).against(:base).with_message(not_following_message) }

        def not_following_message
          I18n.t('accounts.pin_errors.following')
        end
      end
    end
  end
end
