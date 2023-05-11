# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Accounts::RelationshipsController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:follows') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:simon) { Fabricate(:account) }
    let(:lewis) { Fabricate(:account) }

    before do
      user.account.follow!(simon)
      lewis.follow!(user.account)
    end

    context 'when provided only one ID' do
      before do
        get :index, params: { id: simon.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:followed_by]).to be false
      end
    end

    context 'when provided multiple IDs' do
      before do
        get :index, params: { id: [simon.id, lewis.id] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns JSON with correct data' do
        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:id]).to eq simon.id.to_s
        expect(json.first[:following]).to be true
        expect(json.first[:showing_reblogs]).to be true
        expect(json.first[:followed_by]).to be false
        expect(json.first[:muting]).to be false
        expect(json.first[:requested]).to be false
        expect(json.first[:domain_blocking]).to be false

        expect(json.second[:id]).to eq lewis.id.to_s
        expect(json.second[:following]).to be false
        expect(json.second[:showing_reblogs]).to be false
        expect(json.second[:followed_by]).to be true
        expect(json.second[:muting]).to be false
        expect(json.second[:requested]).to be false
        expect(json.second[:domain_blocking]).to be false
      end

      it 'returns JSON with correct data on cached requests too' do
        get :index, params: { id: [simon.id] }

        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be true
        expect(json.first[:showing_reblogs]).to be true
      end

      it 'returns JSON with correct data after change too' do
        user.account.unfollow!(simon)

        get :index, params: { id: [simon.id] }

        json = body_as_json

        expect(json).to be_a Enumerable
        expect(json.first[:following]).to be false
        expect(json.first[:showing_reblogs]).to be false
      end
    end
  end
end
