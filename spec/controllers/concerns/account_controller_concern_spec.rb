# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountControllerConcern do
  controller(ApplicationController) do
    include AccountControllerConcern

    def success
      render plain: @account.username # rubocop:disable RSpec/InstanceVariable
    end
  end

  before do
    routes.draw { get 'success' => 'anonymous#success' }
  end

  context 'when account is unconfirmed' do
    it 'returns http not found' do
      account = Fabricate(:user, confirmed_at: nil).account
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(404)
    end
  end

  context 'when account is not approved' do
    it 'returns http not found' do
      Setting.registrations_mode = 'approved'
      account = Fabricate(:user, approved: false).account
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(404)
    end
  end

  context 'when account is suspended' do
    it 'returns http gone' do
      account = Fabricate(:account, suspended: true)
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(410)
    end
  end

  context 'when account is deleted by owner' do
    it 'returns http gone' do
      account = Fabricate(:account, suspended: true, user: nil)
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(410)
    end
  end

  context 'when account is not suspended' do
    let(:account) { Fabricate(:account, username: 'username') }

    it 'Prepares the account, returns success, and sets link headers' do
      get 'success', params: { account_username: account.username }

      expect(response)
        .to have_http_status(200)
        .and have_http_link_header('http://test.host/.well-known/webfinger?resource=acct%3Ausername%40cb6e6126.ngrok.io').for(rel: 'lrdd', type: 'application/jrd+json')
        .and have_http_link_header('https://cb6e6126.ngrok.io/users/username').for(rel: 'alternate', type: 'application/activity+json')
      expect(response.body)
        .to include(account.username)
    end
  end
end
