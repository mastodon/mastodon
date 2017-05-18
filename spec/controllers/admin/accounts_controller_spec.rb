require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  render_views

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
    let(:account) { Fabricate(:account, username: 'bob') }

    it 'returns http success' do
      get :show, params: { id: account.id }
      expect(response).to have_http_status(:success)
    end
  end
end
