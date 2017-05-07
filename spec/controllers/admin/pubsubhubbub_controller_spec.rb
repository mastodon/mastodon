# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Admin::PubsubhubbubController, type: :controller do
  render_views

  describe 'GET #index' do
    before do
      sign_in Fabricate(:user, admin: true), scope: :user
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
