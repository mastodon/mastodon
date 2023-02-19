# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Instances::ActivityController, type: :controller do
  describe 'GET #show' do
    it 'returns 200' do
      get :show
      expect(response).to have_http_status(:ok)
    end

    context '!Setting.activity_api_enabled' do
      it 'returns 404' do
        Setting.activity_api_enabled = false

        get :show
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
