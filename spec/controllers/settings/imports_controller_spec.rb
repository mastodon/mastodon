require 'rails_helper'

RSpec.describe Settings::ImportsController, type: :controller do

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'redirects to settings path' do
      post :create, params: { import: { type: 'following' } }

      expect(response).to be_redirect(settings_import_path)
    end
  end
end
