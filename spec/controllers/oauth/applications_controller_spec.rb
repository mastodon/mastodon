require 'rails_helper'

RSpec.describe Oauth::ApplicationsController, type: :controller do
  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'redirects to the application page'
  end
end
