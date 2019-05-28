# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Timelines::DirectController, type: :controller do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses') }

  describe 'GET #show' do
    it 'returns 200' do
      allow(controller).to receive(:doorkeeper_token) { token }
      get :show

      expect(response).to have_http_status(200)
    end
  end
end
