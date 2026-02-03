# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Accounts' do
  describe 'POST /admin/accounts/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_accounts_path(form_account_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_accounts_path)
    end
  end

  describe 'POST /admin/accounts/:id/enable' do
    let(:account) { user.account }
    let(:user) { Fabricate(:user, disabled: true) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      before { sign_in current_user }

      it 'fails to enable account' do
        post enable_admin_account_path(id: account.id)

        expect(response)
          .to have_http_status(403)
        expect(user.reload)
          .to be_disabled
      end
    end
  end

  describe 'POST /admin/accounts/:id/approve' do
    let(:account) { user.account }
    let(:user) { Fabricate(:user) }

    before { account.user.update(approved: false) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      before { sign_in current_user }

      it 'fails to approve account' do
        post approve_admin_account_path(id: account.id)

        expect(response)
          .to have_http_status(403)
        expect(user.reload)
          .to_not be_approved
      end
    end
  end

  describe 'POST /admin/accounts/:id/reject' do
    let(:account) { user.account }
    let(:user) { Fabricate(:user) }

    before { account.user.update(approved: false) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      it 'fails to reject account' do
        post reject_admin_account_path(id: account.id)

        expect(response)
          .to have_http_status(403)
        expect(user.reload)
          .to_not be_approved
      end
    end
  end
end
