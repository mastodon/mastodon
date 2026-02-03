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

  describe 'POST /admin/accounts/:id/redownload' do
    let(:account) { Fabricate(:account, domain: 'example.com', last_webfingered_at: 10.days.ago) }
    let(:service) { instance_double(ResolveAccountService, call: nil) }

    before { allow(ResolveAccountService).to receive(:new).and_return(service) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      it 'fails to redownload' do
        post redownload_admin_account_path(id: account.id)

        expect(response)
          .to have_http_status(403)
        expect(account.reload.last_webfingered_at)
          .to_not be_nil
      end
    end
  end

  describe 'POST /admin/accounts/:id/remove_avatar' do
    let(:account) { Fabricate(:account) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      it 'fails to remove avatar' do
        expect { post remove_avatar_admin_account_path(id: account.id) }
          .to_not change(Admin::ActionLog.where(action: 'remove_avatar'), :count)

        expect(response)
          .to have_http_status(403)
      end
    end
  end

  describe 'POST /admin/accounts/:id/unblock_email' do
    let(:account) { Fabricate(:account, suspended: true) }

    before { Fabricate(:canonical_email_block, reference_account: account) }

    context 'when user is not admin' do
      let(:current_user) { Fabricate(:user, role: UserRole.everyone) }

      it 'fails to unblock email' do
        expect { post unblock_email_admin_account_path(id: account.id) }
          .to_not change(CanonicalEmailBlock.where(reference_account: account), :count)

        expect(response)
          .to have_http_status(403)
      end
    end
  end
end
