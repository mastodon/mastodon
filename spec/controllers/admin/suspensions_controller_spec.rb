require 'rails_helper'

describe Admin::SuspensionsController do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'POST #create' do
    it 'redirects to admin accounts page' do
      account = Fabricate(:account, suspended: false)
      expect(Admin::SuspensionWorker).to receive(:perform_async).with(account.id)

      post :create, params: { account_id: account.id }

      expect(response).to redirect_to(admin_accounts_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to admin accounts page' do
      account = Fabricate(:account, suspended: true)

      delete :destroy, params: { account_id: account.id }

      account.reload
      expect(account.suspended?).to eq false
      expect(response).to redirect_to(admin_accounts_path)
    end
  end
end
