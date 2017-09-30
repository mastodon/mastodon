require 'rails_helper'

RSpec.describe Api::V1::DomainBlocksController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow') }

  before do
    user.account.block_domain!('example.com')
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    before do
      get :show, params: { limit: 1 }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns blocked domains' do
      expect(body_as_json.first).to eq 'example.com'
    end
  end

  describe 'POST #create' do
    before do
      post :create, params: { domain: 'example.org' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates a domain block' do
      expect(user.account.domain_blocking?('example.org')).to be true
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, params: { domain: 'example.com' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'deletes a domain block' do
      expect(user.account.domain_blocking?('example.com')).to be false
    end
  end
end
