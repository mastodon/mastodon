# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::HomeController do
  render_views

  let(:user) { Fabricate(:user, current_sign_in_at: 1.day.ago) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses') }

    describe 'GET #show' do
      before do
        follow = Fabricate(:follow, account: user.account)
        PostStatusService.new.call(follow.target_account, text: 'New status for user home timeline.')
      end

      it 'returns http success' do
        get :show

        expect(response).to have_http_status(200)
        expect(response.headers['Link'].links.size).to eq(2)
      end
    end
  end

  context 'without a user context' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: nil, scopes: 'read') }

    describe 'GET #show' do
      it 'returns http unprocessable entity' do
        get :show

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.headers['Link']).to be_nil
      end
    end
  end
end
