# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SuggestionsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:bob) { Fabricate(:account) }
    let(:jeff) { Fabricate(:account) }

    before do
      PotentialFriendshipTracker.record(user.account_id, bob.id, :reblog)
      PotentialFriendshipTracker.record(user.account_id, jeff.id, :favourite)

      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns accounts' do
      json = body_as_json

      expect(json.size).to be >= 1
      expect(json.pluck(:id)).to include(*[bob, jeff].map { |i| i.id.to_s })
    end
  end
end
