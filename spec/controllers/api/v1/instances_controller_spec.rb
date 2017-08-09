# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::InstancesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id) }

  before do
    Fabricate(:setting)
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show

      expect(response).to have_http_status(:success)
    end

    it 'returns instance parameter' do
      get :show

      body = JSON.parse(response.body)
      expect(body['announcement']).to eq 'test_value'
    end
  end
end
