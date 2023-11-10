# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::FollowingAccountsController do
  render_views

  describe 'GET #index' do
    let(:user) { Fabricate(:user) }

    before do
      user.account.follow!(Fabricate(:account, username: 'username', domain: 'domain'))
      sign_in user, scope: :user
    end

    it 'returns a csv of the following accounts' do
      get :index, format: :csv

      expect(response.body)
        .to eq expected_csv_body
    end

    private

    def expected_csv_body
      <<~CSV
        Account address,Show boosts,Notify on new posts,Languages
        username@domain,true,false,
      CSV
    end
  end
end
