# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::CanonicalEmailBlocksController do
  render_views

  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
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

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of canonical email blocks' do
          get :index, params: params

          json = body_as_json

          expect(json.size).to eq(params[:limit])
        end
      end

      context 'with since_id param' do
        let(:params) { { since_id: canonical_email_blocks[1].id } }

        it 'returns only the canonical email blocks after since_id' do
          get :index, params: params

          canonical_email_blocks_ids = canonical_email_blocks.pluck(:id).map(&:to_s)
          json = body_as_json

          expect(json.pluck(:id)).to match_array(canonical_email_blocks_ids[2..])
        end
      end

      context 'with max_id param' do
        let(:params) { { max_id: canonical_email_blocks[3].id } }

        it 'returns only the canonical email blocks before max_id' do
          get :index, params: params

          canonical_email_blocks_ids = canonical_email_blocks.pluck(:id).map(&:to_s)
          json = body_as_json

          expect(json.pluck(:id)).to match_array(canonical_email_blocks_ids[..2])
        end
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

  describe 'POST #create' do
    let(:params) { { email: 'example@email.com' } }
    let(:canonical_email_block) { CanonicalEmailBlock.new(email: params[:email]) }

    context 'with wrong scope' do
      before do
        post :create, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        post :create, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      post :create, params: params

      expect(response).to have_http_status(200)
    end

    it 'returns canonical_email_hash correctly' do
      post :create, params: params

      json = body_as_json

      expect(json[:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
    end

    context 'when required email param is not provided' do
      it 'returns http unprocessable entity' do
        post :create

        expect(response).to have_http_status(422)
      end
    end

    context 'when canonical_email_hash param is provided instead of email' do
      let(:params) { { canonical_email_hash: 'dd501ce4e6b08698f19df96f2f15737e48a75660b1fa79b6ff58ea25ee4851a4' } }

      it 'returns http success' do
        post :create, params: params

        expect(response).to have_http_status(200)
      end

      it 'returns correct canonical_email_hash' do
        post :create, params: params

        json = body_as_json

        expect(json[:canonical_email_hash]).to eq(params[:canonical_email_hash])
      end
    end

    context 'when both email and canonical_email_hash params are provided' do
      let(:params) { { email: 'example@email.com', canonical_email_hash: 'dd501ce4e6b08698f19df96f2f15737e48a75660b1fa79b6ff58ea25ee4851a4' } }

      it 'returns http success' do
        post :create, params: params

        expect(response).to have_http_status(200)
      end

      it 'ignores canonical_email_hash param' do
        post :create, params: params

        json = body_as_json

        expect(json[:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
      end
    end

    context 'when canonical email was already blocked' do
      before do
        canonical_email_block.save
      end

      it 'returns http unprocessable entity' do
        post :create, params: params

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:canonical_email_block) { Fabricate(:canonical_email_block) }
    let(:params) { { id: canonical_email_block.id } }

    context 'with wrong scope' do
      before do
        delete :destroy, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with wrong role' do
      before do
        delete :destroy, params: params
      end

      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'forbidden for wrong role', 'Moderator'
    end

    it 'returns http success' do
      delete :destroy, params: params

      expect(response).to have_http_status(200)
    end

    context 'when canonical email block is not found' do
      it 'returns http not found' do
        delete :destroy, params: { id: 0 }

        expect(response).to have_http_status(404)
      end
    end
  end
end
