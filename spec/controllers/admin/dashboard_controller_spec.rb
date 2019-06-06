# frozen_string_literal: true

require 'rails_helper'

describe Admin::DashboardController, type: :controller do
  describe 'GET #index' do
    it 'returns 200' do
      sign_in Fabricate(:user, admin: true)
      get :index

      expect(response).to have_http_status(200)
    end
  end
end
