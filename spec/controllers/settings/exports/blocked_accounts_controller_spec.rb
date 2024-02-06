# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::BlockedAccountsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the blocking accounts' do
      user = Fabricate(:user)
      user.account.block!(Fabricate(:account, username: 'username', domain: 'domain'))

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "username@domain\n"
    end
  end
end
