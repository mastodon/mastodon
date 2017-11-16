require 'rails_helper'

RSpec.describe Api::V1::MutesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow') }

  before do
    Fabricate(:mute, account: user.account, hide_notifications: false)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { limit: 1 }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #details' do
    before do
      get :details, params: { limit: 1 }
    end

    let(:mutes) { JSON.parse(response.body) }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns one mute' do
      expect(mutes.size).to be(1)
    end

    it 'returns whether the mute hides notifications' do
      expect(mutes.first["hide_notifications"]).to be(false)
    end 
  end
end
