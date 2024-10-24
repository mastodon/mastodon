# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardHelper do
  describe 'relevant_account_timestamp' do
    subject { helper.relevant_account_timestamp(account) }

    context 'with an account with older sign in' do
      let(:account) { Fabricate(:account) }
      let(:stamp) { 10.days.ago }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: stamp)
        expect(subject)
          .to match('time-ago')
          .and match(I18n.l(stamp))
      end
    end

    context 'with an account with newer sign in' do
      let(:account) { Fabricate(:account) }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: 10.hours.ago)

        expect(subject)
          .to eq(I18n.t('generic.today'))
          .and not_include('time-ago')
      end
    end

    context 'with an account where the user is pending' do
      let(:account) { Fabricate(:account) }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: nil)
        account.user.update(approved: false)

        expect(subject)
          .to match('time-ago')
          .and match(I18n.l(account.user.created_at))
      end
    end

    context 'with a local account without a user that is suspended' do
      let(:account) { Fabricate(:account, suspended_at: 5.days.ago, user: nil) }

      it 'returns a time element' do
        expect(subject)
          .to match('time-ago')
          .and match(I18n.l(account.suspended_at))
      end
    end

    context 'with an account with a last status value' do
      let(:account) { Fabricate(:account) }
      let(:stamp) { 5.minutes.ago }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: nil)
        account.account_stat.update(last_status_at: stamp)

        expect(subject)
          .to match('time-ago')
          .and match(I18n.l(stamp))
      end
    end

    context 'with an account without sign in or last status or pending' do
      let(:account) { Fabricate(:account) }

      it 'returns a time element' do
        account.user.update(current_sign_in_at: nil)

        expect(subject)
          .to eq('-')
          .and not_include('time-ago')
      end
    end
  end
end
