# frozen_string_literal: true

require 'rails_helper'

describe AccountControllerConcern do
  controller(ApplicationController) do
    include AccountControllerConcern

    def success
      head 200
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

  context 'when account is permanently suspended' do
    it 'returns http gone' do
      account = Fabricate(:account, suspended: true)
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(410)
    end
  end

  context 'when account is temporarily suspended' do
    it 'returns http forbidden' do
      account = Fabricate(:account)
      account.suspend!
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(403)
    end
  end

  context 'when account is permanently deleted' do
    it 'returns http gone' do
      account = Fabricate(:account, deleted: true)
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(410)
    end
  end

  context 'when account is pending deletion' do
    it 'returns http forbidden' do
      account = Fabricate(:account)
      account.mark_deleted!
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(403)
    end
  end

  context 'when account is not suspended' do
    let(:account) { Fabricate(:account, username: 'username') }

    it 'assigns @account, returns success, and sets link headers' do
      get 'success', params: { account_username: account.username }

      expect(assigns(:account)).to eq account
      expect(response).to have_http_status(200)
      expect(response.headers['Link'].to_s).to eq(expected_link_headers)
    end

    def expected_link_headers
      [
        '<http://test.host/.well-known/webfinger?resource=acct%3Ausername%40cb6e6126.ngrok.io>; rel="lrdd"; type="application/jrd+json"',
        '<https://cb6e6126.ngrok.io/users/username>; rel="alternate"; type="application/activity+json"',
      ].join(', ')
    end
  end
end
