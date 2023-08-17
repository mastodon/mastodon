# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::BlockedDomainsController do
  render_views

  describe 'GET #index' do
    it 'returns a csv of the domains' do
      account = Fabricate(:account, domain: 'example.com')
      user = Fabricate(:user, account: account)
      Fabricate(:account_domain_block, domain: 'example.com', account: account)

      sign_in user, scope: :user
      get :index, format: :csv

      expect(response.body).to eq "example.com\n"
    end
  end
end
