require 'rails_helper'

describe Settings::FollowerDomainsController do
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

  describe 'PATCH #update' do
    let(:poopfeast) { Fabricate(:account, username: 'poopfeast', domain: 'example.com', salmon_url: 'http://example.com/salmon') }

    before do
      stub_request(:post, 'http://example.com/salmon').to_return(status: 200)
      poopfeast.follow!(user.account)
      patch :update, params: { select: ['example.com'] }
    end

    it 'redirects back to followers page' do
      expect(response).to redirect_to(settings_follower_domains_path)
    end

    it 'soft-blocks followers from selected domains' do
      expect(poopfeast.following?(user.account)).to be false
    end
  end
end
