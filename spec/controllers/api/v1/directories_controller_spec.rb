# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::DirectoriesController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:follows') }
  let(:account) { Fabricate(:account) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show

      expect(response).to have_http_status(200)
    end
  end
end
