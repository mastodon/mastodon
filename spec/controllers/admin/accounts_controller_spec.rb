require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success)
    end
  end
end
