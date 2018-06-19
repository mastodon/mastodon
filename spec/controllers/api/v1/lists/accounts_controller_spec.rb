require 'rails_helper'

describe Api::V1::Lists::AccountsController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read write') }
  let(:list)  { Fabricate(:list, account: user.account) }

  before do
    follow = Fabricate(:follow, account: user.account)
    list.accounts << follow.target_account
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :show, params: { list_id: list.id }

      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    let(:bob) { Fabricate(:account, username: 'bob') }

    before do
      user.account.follow!(bob)
      post :create, params: { list_id: list.id, account_ids: [bob.id] }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'adds account to the list' do
      expect(list.accounts.include?(bob)).to be true
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, params: { list_id: list.id, account_ids: [list.accounts.first.id] }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes account from the list' do
      expect(list.accounts.count).to eq 0
    end
  end
end
