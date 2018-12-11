require 'rails_helper'

describe Admin::SuspensionsController do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #new' do
    it 'returns 200' do
      get :new, params: { account_id: Fabricate(:account).id, report_id: Fabricate(:report).id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    it 'redirects to admin accounts page' do
      account = Fabricate(:account, suspended: false)
      expect(Admin::SuspensionWorker).to receive(:perform_async).with(account.id)

      post :create, params: { account_id: account.id, form_admin_suspension_confirmation: { acct: account.acct } }

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
