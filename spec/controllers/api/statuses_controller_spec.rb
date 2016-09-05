require 'rails_helper'

RSpec.describe Api::StatusesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    stub_request(:post, "https://pubsubhubbub.superfeedr.com/").to_return(:status => 200, :body => "", :headers => {})
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    let(:status) { Fabricate(:status, account: user.account) }

    it 'returns http success' do
      get :show, params: { id: status.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #home' do
    it 'returns http success' do
      get :home
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #mentions' do
    it 'returns http success' do
      get :mentions
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      post :create, params: { status: 'Hello world' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #reblog' do
    let(:status) { Fabricate(:status, account: user.account) }

    before do
      post :reblog, params: { id: status.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'updates the reblogs count' do
      expect(status.reblogs_count).to eq 1
    end

    it 'updates the reblogged attribute' do
      expect(user.account.reblogged?(status)).to be true
    end

    it 'return json with updated attributes' do
      hash_body = body_as_json

      expect(hash_body[:reblog][:id]).to eq status.id
      expect(hash_body[:reblog][:reblogs_count]).to eq 1
      expect(hash_body[:reblog][:reblogged]).to be true
    end
  end

  describe 'POST #favourite' do
    let(:status) { Fabricate(:status, account: user.account) }

    before do
      post :favourite, params: { id: status.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'updates the favourites count' do
      expect(status.favourites_count).to eq 1
    end

    it 'updates the favourited attribute' do
      expect(user.account.favourited?(status)).to be true
    end

    it 'return json with updated attributes' do
      hash_body = body_as_json

      expect(hash_body[:id]).to eq status.id
      expect(hash_body[:favourites_count]).to eq 1
      expect(hash_body[:favourited]).to be true
    end
  end
end
