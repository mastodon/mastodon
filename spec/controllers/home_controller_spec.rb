require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'redirects to login page' do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
