# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountOwnedConcern do
  controller(ApplicationController) do
    include AccountOwnedConcern

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

    it 'Prepares the account and returns success' do
      get 'success', params: { account_username: account.username }

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to include(account.username)
    end
  end
end
