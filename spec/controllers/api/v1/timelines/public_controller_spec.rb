# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::PublicController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id) }

    describe 'GET #show' do
      before do
        PostStatusService.new.call(user.account, 'New status from user for federated public timeline.')
      end

      it 'returns http success' do
        get :show

        expect(response).to have_http_status(:success)
        expect(response.headers['Link'].links.size).to eq(2)
      end
    end

    describe 'GET #show with local only' do
      before do
        PostStatusService.new.call(user.account, 'New status from user for local public timeline.')
      end

      it 'returns http success' do
        get :show, params: { local: true }

        expect(response).to have_http_status(:success)
        expect(response.headers['Link'].links.size).to eq(2)
      end
    end
  end

  context 'without a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil) }

    describe 'GET #show' do
      it 'returns http success' do
        get :show

        expect(response).to have_http_status(:success)
        expect(response.headers['Link']).to be_nil
      end
    end
  end
end
