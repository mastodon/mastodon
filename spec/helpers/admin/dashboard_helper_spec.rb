# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardHelper do
  describe 'relevant_account_timestamp' do
    context 'with an account with older sign in' do
      let(:account) { Fabricate(:account) }
      let(:stamp) { 10.days.ago }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: stamp)
        result = helper.relevant_account_timestamp(account)

        expect(result).to match('time-ago')
        expect(result).to match(I18n.l(stamp))
      end
    end

    context 'with an account with newer sign in' do
      let(:account) { Fabricate(:account) }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: 10.hours.ago)
        result = helper.relevant_account_timestamp(account)

        expect(result).to eq(I18n.t('generic.today'))
      end
    end

    context 'with an account where the user is pending' do
      let(:account) { Fabricate(:account) }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: nil)
        account.user.update(approved: false)
        result = helper.relevant_account_timestamp(account)

        expect(result).to match('time-ago')
        expect(result).to match(I18n.l(account.user.created_at))
      end
    end

    context 'with an account with a last status value' do
      let(:account) { Fabricate(:account) }
      let(:stamp) { 5.minutes.ago }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: nil)
        account.account_stat.update(last_status_at: stamp)
        result = helper.relevant_account_timestamp(account)

        expect(result).to match('time-ago')
        expect(result).to match(I18n.l(stamp))
      end
    end

    context 'with an account without sign in or last status or pending' do
      let(:account) { Fabricate(:account) }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: nil)
        result = helper.relevant_account_timestamp(account)

        expect(result).to eq('-')
      end
    end
  end
end
