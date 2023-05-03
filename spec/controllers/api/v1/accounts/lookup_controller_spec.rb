# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Accounts::LookupController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts') }
  let(:account) { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { account_id: account.id, acct: account.acct }

      expect(response).to have_http_status(200)
    end
  end
end
