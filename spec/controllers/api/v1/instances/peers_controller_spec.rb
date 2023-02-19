# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Instances::PeersController, type: :controller do
  describe 'GET #index' do
    it 'returns 200' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    context '!Setting.peers_api_enabled' do
      it 'returns 404' do
        Setting.peers_api_enabled = false

        get :index
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
