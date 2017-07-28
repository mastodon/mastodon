# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SearchController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { q: 'test' }

      expect(response).to have_http_status(:success)
    end
  end
end
