require 'rails_helper'

describe Settings::Exports::FollowingAccountsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the following accounts' do
      user = Fabricate(:user)
      user.account.follow!(Fabricate(:account, username: 'username', domain: 'domain'))

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "Account address,Show boosts,Notify on new posts,Languages\nusername@domain,true,false,\n"
    end
  end
end
