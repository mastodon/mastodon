require 'rails_helper'

describe FollowingAccountsController do
  render_views
  let(:alice) { Fabricate(:account, username: 'alice') }

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { account_username: alice.username }

      expect(response).to have_http_status(:success)
    end
  end
end
