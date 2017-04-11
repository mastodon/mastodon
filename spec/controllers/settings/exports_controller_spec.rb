require 'rails_helper'

describe Settings::ExportsController do
  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end
end
