# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::FollowerAccountsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the follower accounts' do
      user = Fabricate(:user)
      Fabricate(:account, username: 'username', domain: 'domain').follow!(user.account)

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "Account address\nusername@domain\n"
    end
  end
end
