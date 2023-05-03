# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::EmailDomainBlocksController do
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
end
