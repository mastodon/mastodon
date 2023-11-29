# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Accounts::FamiliarFollowersController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:follows') }
  let(:account) { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_id: account.id, limit: 2 }

      expect(response).to have_http_status(200)
    end

    context 'when there are duplicate account IDs in the params' do
      let(:account_a) { Fabricate(:account) }
      let(:account_b) { Fabricate(:account) }

      it 'removes duplicate account IDs from params' do
        account_ids = [account_a, account_b, account_b, account_a, account_a].map { |a| a.id.to_s }
        get :index, params: { id: account_ids }

        expect(body_as_json.pluck(:id)).to eq [account_a.id.to_s, account_b.id.to_s]
      end
    end
  end
end
