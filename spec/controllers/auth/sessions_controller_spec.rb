require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :controller do
  describe 'GET #new' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:user) { Fabricate(:user, email: 'foo@bar.com', password: 'abcdefgh') }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, user: { email: user.email, password: user.password }
    end

    it 'redirects to home page' do
      expect(response).to redirect_to(root_path)
    end

    it 'logs the user in' do
      expect(controller.current_user).to eq user
    end
  end
end
