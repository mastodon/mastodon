# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts Pins API' do
  let(:user)     { Fabricate(:user) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'write:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }
  let(:kevin) { Fabricate(:user) }

  before do
    kevin.account.followers << user.account
  end

  describe 'GET /api/v1/accounts/:account_id/endorsements' do
    subject { get "/api/v1/accounts/#{user.account.id}/endorsements", headers: headers }

    let(:scopes) { 'read:accounts' }

    before do
      user.account.endorsed_accounts << kevin.account
    end

    it 'returns the expected accounts', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to contain_exactly(
          hash_including(id: kevin.account_id.to_s)
        )
    end
  end

  describe 'POST /api/v1/accounts/:account_id/endorse' do
    subject { post "/api/v1/accounts/#{kevin.account.id}/endorse", headers: headers }

    it 'creates account_pin', :aggregate_failures do
      expect do
        subject
      end.to change { AccountPin.where(account: user.account, target_account: kevin.account).count }.by(1)
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/accounts/:account_id/unendorse' do
    subject { post "/api/v1/accounts/#{kevin.account.id}/unendorse", headers: headers }

    before do
      Fabricate(:account_pin, account: user.account, target_account: kevin.account)
    end

    it 'destroys account_pin', :aggregate_failures do
      expect do
        subject
      end.to change { AccountPin.where(account: user.account, target_account: kevin.account).count }.by(-1)
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end
end
