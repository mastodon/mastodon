# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::ListController do
  render_views

  let(:user) { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:list) { Fabricate(:list, account: user.account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

    describe 'GET #show' do
      before do
        follow = Fabricate(:follow, account: user.account)
        list.accounts << follow.target_account
        PostStatusService.new.call(follow.target_account, 'New status for user home timeline.')
      end

      it 'returns http success' do
        get :show, params: { id: list.id }
        expect(response).to have_http_status(200)
      end
    end
  end

  context 'with the wrong user context' do
    let(:other_user) { Fabricate(:user, account: Fabricate(:account, username: 'bob')) }
    let(:token)      { Fabricate(:accessible_access_token, resource_owner_id: other_user.id, scopes: 'read') }

    describe 'GET #show' do
      it 'returns http not found' do
        get :show, params: { id: list.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'without a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: 'read') }

    describe 'GET #show' do
      it 'returns http unprocessable entity' do
        get :show, params: { id: list.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.headers['Link']).to be_nil
      end
    end
  end
end
