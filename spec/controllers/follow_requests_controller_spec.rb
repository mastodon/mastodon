require 'rails_helper'

RSpec.describe FollowRequestsController, type: :controller do
  render_views

  before do
    sign_in Fabricate(:user), scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
