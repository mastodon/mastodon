require 'rails_helper'

describe FollowerAccountsController do
  render_views

  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:follower0) { Fabricate(:account) }
  let(:follower1) { Fabricate(:account) }

  describe 'GET #index' do
    it 'assigns follows' do
      follow0 = follower0.follow!(alice)
      follow1 = follower1.follow!(alice)

      get :index, params: { account_username: alice.username }

      assigned = assigns(:follows).to_a
      expect(assigned.size).to eq 2
      expect(assigned[0]).to eq follow1
      expect(assigned[1]).to eq follow0

      expect(response).to have_http_status(200)
    end
  end
end
