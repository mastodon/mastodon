# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::CanonicalEmailBlocksController do
  render_views

  let(:user)    { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'admin:read') }
  let(:account) { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #test' do
    context 'when required email is not provided' do
      it 'returns http bad request' do
        post :test

        expect(response).to have_http_status(400)
      end
    end

    context 'when required email is provided' do
      let(:params) { { email: 'example@email.com' } }

      context 'when there is a matching canonical email block' do
        let!(:canonical_email_block) { CanonicalEmailBlock.create(params) }

        it 'returns http success' do
          post :test, params: params

          expect(response).to have_http_status(200)
        end

        it 'returns expected canonical email hash' do
          post :test, params: params

          json = body_as_json

          expect(json[0][:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
        end
      end

      context 'when there is no matching canonical email block' do
        it 'returns http success' do
          post :test, params: params

          expect(response).to have_http_status(200)
        end

        it 'returns an empty list' do
          post :test, params: params

          json = body_as_json

          expect(json).to be_empty
        end
      end
    end
  end
end
