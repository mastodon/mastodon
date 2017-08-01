# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Statuses::FavouritesController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:app)   { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write', application: app) }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'POST #create' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        post :create, params: { status_id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the favourites count' do
        expect(status.favourites.count).to eq 1
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

    describe 'POST #destroy' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        FavouriteService.new.call(user.account, status)
        post :destroy, params: { status_id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the favourites count' do
        expect(status.favourites.count).to eq 0
      end

      it 'updates the favourited attribute' do
        expect(user.account.favourited?(status)).to be false
      end
    end
  end
end
