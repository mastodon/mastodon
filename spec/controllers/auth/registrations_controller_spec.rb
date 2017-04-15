require 'rails_helper'

RSpec.describe Auth::RegistrationsController, type: :controller do
  render_views

  describe 'GET #new' do
    before do
      Setting.open_registrations = true
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      Setting.open_registrations = true
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, params: { user: { account_attributes: { username: 'test' }, email: 'test@example.com', password: '12345678', password_confirmation: '12345678' } }
    end

    it 'redirects to login page' do
      expect(response).to redirect_to new_user_session_path
    end

    it 'creates user' do
      expect(User.find_by(email: 'test@example.com')).to_not be_nil
    end
  end
end
