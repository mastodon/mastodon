require 'rails_helper'

RSpec.describe Admin::InstancesController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      account = Fabricate(:account, domain: 'example.com')
      get :show, params: { id: 'example.com' }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end
  end
end
