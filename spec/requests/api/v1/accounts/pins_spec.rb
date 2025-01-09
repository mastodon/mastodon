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

  describe 'POST /api/v1/accounts/:account_id/pin' do
    subject { post "/api/v1/accounts/#{kevin.account.id}/pin", headers: headers }

    it 'creates account_pin', :aggregate_failures do
      expect do
        subject
      end.to change { AccountPin.where(account: user.account, target_account: kevin.account).count }.by(1)
      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end
  end

  describe 'POST /api/v1/accounts/:account_id/unpin' do
    subject { post "/api/v1/accounts/#{kevin.account.id}/unpin", headers: headers }

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
