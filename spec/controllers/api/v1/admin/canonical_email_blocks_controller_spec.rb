# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::CanonicalEmailBlocksController do
  render_views

  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:account) { Fabricate(:account) }
  let(:scopes)  { 'admin:read:canonical_email_blocks admin:write:canonical_email_blocks' }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  shared_examples 'forbidden for wrong role' do |wrong_role|
    let(:role) { UserRole.find_by(name: wrong_role) }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'GET #index' do
    context 'with wrong scope' do
      before do
        get :index
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        get :index
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      get :index

      expect(response).to have_http_status(200)
    end

    context 'when there is no canonical email block' do
      it 'returns an empty list' do
        get :index

        body = body_as_json

        expect(body).to be_empty
      end
    end

    context 'when there are canonical email blocks' do
      let!(:canonical_email_blocks) { Fabricate.times(5, :canonical_email_block) }
      let(:expected_email_hashes) { canonical_email_blocks.pluck(:canonical_email_hash) }

      it 'returns the correct canonical email hashes' do
        get :index

        json = body_as_json

        expect(json.pluck(:canonical_email_hash)).to match_array(expected_email_hashes)
      end
    end
  end

  describe 'GET #show' do
    let!(:canonical_email_block) { Fabricate(:canonical_email_block) }
    let(:params) { { id: canonical_email_block.id } }

    context 'with wrong scope' do
      before do
        get :show, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        get :show, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    context 'when canonical email block exists' do
      it 'returns http success' do
        get :show, params: params

        expect(response).to have_http_status(200)
      end

      it 'returns canonical email block data correctly' do
        get :show, params: params

        json = body_as_json

        expect(json[:id]).to eq(canonical_email_block.id.to_s)
        expect(json[:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
      end
    end

    context 'when canonical block does not exist' do
      it 'returns http not found' do
        get :show, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #test' do
    context 'with wrong scope' do
      before do
        post :test
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        post :test, params: { email: 'whatever@email.com' }
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

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
