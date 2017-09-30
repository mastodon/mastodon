require 'rails_helper'

describe Api::V1::Accounts::StatusesController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

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

    context 'with only media' do
      it 'returns http success' do
        get :index, params: { account_id: user.account.id, only_media: true }

        expect(response).to have_http_status(:success)
      end
    end

    context 'with exclude replies' do
      before do
        Fabricate(:status, account: user.account, thread: Fabricate(:status))
      end

      it 'returns http success' do
        get :index, params: { account_id: user.account.id, exclude_replies: true }

        expect(response).to have_http_status(:success)
      end
    end

    context 'with only pinned' do
      before do
        Fabricate(:status_pin, account: user.account, status: Fabricate(:status, account: user.account))
      end

      it 'returns http success' do
        get :index, params: { account_id: user.account.id, pinned: true }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
