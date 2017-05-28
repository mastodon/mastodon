require 'rails_helper'

describe Settings::Exports::MutedAccountsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the muting accounts' do
      user = Fabricate(:user)
      user.account.mute!(Fabricate(:account, username: 'username', domain: 'domain'))

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response).to have_http_status(:success)
      expect(response.body).to eq "username@domain\n"
      expect(response.content_type).to eq 'text/csv'
      expect(response.headers['Content-Disposition']).to eq 'attachment; filename="muted_accounts.csv"'
    end
  end
end
