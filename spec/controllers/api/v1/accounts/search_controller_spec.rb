# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Accounts::SearchController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:accounts') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { q: 'query' }

      expect(response).to have_http_status(200)
    end
  end
end
