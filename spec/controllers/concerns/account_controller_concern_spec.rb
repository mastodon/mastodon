# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController do
  controller do
    include AccountControllerConcern

    def success
      head 200
    end
  end

  around do |example|
    registrations_mode = Setting.registrations_mode
    example.run
    Setting.registrations_mode = registrations_mode
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
    it 'assigns @account' do
      account = Fabricate(:account)
      get 'success', params: { account_username: account.username }
      expect(assigns(:account)).to eq account
    end

    it 'sets link headers' do
      account = Fabricate(:account, username: 'username')
      get 'success', params: { account_username: 'username' }
      expect(response.headers['Link'].to_s).to eq '<http://test.host/.well-known/webfinger?resource=acct%3Ausername%40cb6e6126.ngrok.io>; rel="lrdd"; type="application/jrd+json", <https://cb6e6126.ngrok.io/users/username>; rel="alternate"; type="application/activity+json"'
    end

    it 'returns http success' do
      account = Fabricate(:account)
      get 'success', params: { account_username: account.username }
      expect(response).to have_http_status(200)
    end
  end
end
