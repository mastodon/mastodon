# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::MutedAccountsController do
  render_views

  describe 'GET #index' do
    let(:user) { Fabricate(:user) }

    before do
      user.account.mute!(Fabricate(:account, username: 'username', domain: 'domain'))
      sign_in user, scope: :user
    end

    it 'returns a csv of the muting accounts' do
      get :index, format: :csv

      expect(response.body)
        .to eq expected_csv_body
    end

    private

    def expected_csv_body
      <<~CSV
        Account address,Hide notifications
        username@domain,true
      CSV
    end
  end
end
