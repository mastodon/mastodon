require 'rails_helper'

RSpec.describe Api::V1::SuggestionsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:alice) { Fabricate(:account) }
    let(:bob) { Fabricate(:account) }

    before do
      user.account.follow!(alice)
      alice.follow!(bob)
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns bob' do
      json = body_as_json

      expect(json.size).to eq 1
      expect(json[0][:id]).to eq bob.id.to_s
    end
  end
end
