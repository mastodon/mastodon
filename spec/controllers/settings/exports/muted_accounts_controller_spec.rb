require 'rails_helper'

describe Settings::Exports::MutedAccountsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the muting accounts' do
      user = Fabricate(:user)
      user.account.mute!(Fabricate(:account, username: 'username', domain: 'domain'))

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "Account address,Hide notifications\nusername@domain,true\n"
    end
  end
end
