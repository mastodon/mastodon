# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Confirmations' do
  before { sign_in Fabricate(:admin_user) }

  describe 'POST /admin/accounts/:account_id/confirmation' do
    context 'when account does not exist' do
      let(:account_id) { 'fake' }

      it 'raises an error' do
        post admin_account_confirmation_path(account_id:)

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'when account does not have a user' do
      let(:account) { Fabricate :account, user: nil }

      it 'raises an error' do
        post admin_account_confirmation_path(account_id: account.id)

        expect(response)
          .to have_http_status(404)
      end
    end
  end

  describe 'POST /admin/accounts/:account_id/confirmation/resend' do
    subject { post resend_admin_account_confirmation_path(account_id: user.account.id) }

    let(:user) { Fabricate(:user, confirmed_at: confirmed_at) }

    context 'when email is confirmed' do
      let(:confirmed_at) { Time.zone.now }

      it 'does not resend confirmation mail' do
        emails = capture_emails { subject }

        expect(emails)
          .to be_empty

        expect(response)
          .to redirect_to admin_accounts_path

        follow_redirect!

        expect(response.body)
          .to include(I18n.t('admin.accounts.resend_confirmation.already_confirmed'))
      end
    end
  end
end
