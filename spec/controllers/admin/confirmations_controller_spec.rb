require 'rails_helper'

RSpec.describe Admin::ConfirmationsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'POST #create' do
    it 'confirms the user' do
      account = Fabricate(:account)
      user = Fabricate(:user, confirmed_at: false, account: account)
      post :create, params: { account_id: account.id }

      expect(response).to redirect_to(admin_accounts_path)
      expect(user.reload).to be_confirmed
    end

    it 'raises an error when there is no account' do
      post :create, params: { account_id: 'fake' }

      expect(response).to have_http_status(:missing)
    end

    it 'raises an error when there is no user' do
      account = Fabricate(:account, user: nil)
      post :create, params: { account_id: account.id }

      expect(response).to have_http_status(:missing)
    end
  end
end
