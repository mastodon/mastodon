require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :controller do
  render_views

  let!(:user) { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:other) { Fabricate(:user, account: Fabricate(:account, username: 'bob')) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:scopes) { 'read:statuses' }

    before do
      PostStatusService.new.call(other.account, text: 'Hey @alice', visibility: 'direct')
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end

    it 'returns pagination headers' do
      get :index, params: { limit: 1 }
      expect(response.headers['Link'].links.size).to eq(2)
    end

    it 'returns conversations' do
      get :index
      json = body_as_json
      expect(json.size).to eq 1
    end
  end
end
