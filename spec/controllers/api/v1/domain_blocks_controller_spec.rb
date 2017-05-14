require 'rails_helper'

RSpec.describe Api::V1::DomainBlocksController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    user.account.block_domain!('example.com')
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
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
end
