require 'rails_helper'

RSpec.describe MediumAccountsController, type: :controller do
  render_views

  let(:alice)  { Fabricate(:account, username: 'alice') }

  describe 'GET #media' do
    it 'returns http success' do
      Rails.application.routes.recognize_path('/users/accounts/media')
      get :index, params: { account_username: alice.username }
      expect(response).to have_http_status(:success)
    end
  end
end
