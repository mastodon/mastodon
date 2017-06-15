require 'rails_helper'

describe Api::V1::Accounts::StatusesController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
    Fabricate(:status, account: user.account)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: user.account.id, limit: 1 }

      expect(response).to have_http_status(:success)
      expect(response.headers['Link'].links.size).to eq(2)
    end
  end

  describe 'GET #index with only media' do
    it 'returns http success' do
      get :index, params: { account_id: user.account.id, only_media: true }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #index with exclude replies' do
    it 'returns http success' do
      get :index, params: { account_id: user.account.id, exclude_replies: true }

      expect(response).to have_http_status(:success)
    end
  end
end
