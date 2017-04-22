require 'rails_helper'

describe Settings::FollowersController do
  let(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #purge' do
    let(:poopfeast) { Fabricate(:account, username: 'poopfeast', domain: 'example.com', salmon_url: 'http://example.com/salmon') }
    before do
      stub_request(:post, 'http://example.com/salmon').to_return(status: 200)
      poopfeast.follow!(user.account)
      post :purge, params: { select: ['example.com'] }
    end

    it 'redirects back to followers page' do
      expect(response).to redirect_to(settings_followers_path)
    end

    it 'soft-blocks followers from selected domains' do
      expect(poopfeast.following?(user.account)).to be false
    end
  end
end
