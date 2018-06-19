require 'rails_helper'

describe Api::V1::Accounts::ListsController do
  render_views

  let(:user)    { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }
  let(:account) { Fabricate(:account) }
  let(:list)    { Fabricate(:list, account: user.account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
    user.account.follow!(account)
    list.accounts << account
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: account.id }
      expect(response).to have_http_status(200)
    end
  end
end
