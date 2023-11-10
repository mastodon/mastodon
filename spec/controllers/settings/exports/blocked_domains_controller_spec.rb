# frozen_string_literal: true

require 'rails_helper'

describe Settings::Exports::BlockedDomainsController do
  render_views

  describe 'GET #index' do
    let(:user) { Fabricate(:user, account: account) }
    let(:account) { Fabricate(:account, domain: 'example.com') }

    before do
      Fabricate(:account_domain_block, domain: 'example.com', account: account)

      sign_in user, scope: :user
    end

    it 'returns a csv of the domains' do
      get :index, format: :csv

      expect(response.body)
        .to eq "example.com\n"
    end
  end
end
