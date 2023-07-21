# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Instances::PeersController do
  describe 'GET #index' do
    it 'returns 200' do
      get :index
      expect(response).to have_http_status(200)
    end

    context 'with !Setting.peers_api_enabled' do
      it 'returns 404' do
        Setting.peers_api_enabled = false

        get :index
        expect(response).to have_http_status(404)
      end
    end
  end
end
