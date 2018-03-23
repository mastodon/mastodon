require 'rails_helper'

describe Admin::SilencesController do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'POST #create' do
    it 'redirects to admin accounts page' do
      account = Fabricate(:account, silenced: false)

      post :create, params: { account_id: account.id }

      account.reload
      expect(account.silenced?).to eq true
      expect(response).to redirect_to(admin_accounts_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to admin accounts page' do
      account = Fabricate(:account, silenced: true)

      delete :destroy, params: { account_id: account.id }

      account.reload
      expect(account.silenced?).to eq false
      expect(response).to redirect_to(admin_accounts_path)
    end
  end
end
