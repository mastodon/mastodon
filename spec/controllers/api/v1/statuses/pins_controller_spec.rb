# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Statuses::PinsController do
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
        expect(response).to have_http_status(200)
      end

      it 'updates the pinned attribute' do
        expect(user.account.pinned?(status)).to be true
      end

      it 'return json with updated attributes' do
        hash_body = body_as_json

        expect(hash_body[:id]).to eq status.id.to_s
        expect(hash_body[:pinned]).to be true
      end
    end

    describe 'POST #destroy' do
      let(:status) { Fabricate(:status, account: user.account) }

      before do
        Fabricate(:status_pin, status: status, account: user.account)
        post :destroy, params: { status_id: status.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'updates the pinned attribute' do
        expect(user.account.pinned?(status)).to be false
      end
    end
  end
end
