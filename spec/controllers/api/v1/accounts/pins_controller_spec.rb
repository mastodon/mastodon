# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Accounts::PinsController do
  let(:john)  { Fabricate(:user) }
  let(:kevin) { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: john.id, scopes: 'write:accounts') }

  before do
    kevin.account.followers << john.account
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    subject { post :create, params: { account_id: kevin.account.id } }

    it 'creates account_pin', :aggregate_failures do
      expect do
        subject
      end.to change { AccountPin.where(account: john.account, target_account: kevin.account).count }.by(1)
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { account_id: kevin.account.id } }

    before do
      Fabricate(:account_pin, account: john.account, target_account: kevin.account)
    end

    it 'destroys account_pin', :aggregate_failures do
      expect do
        subject
      end.to change { AccountPin.where(account: john.account, target_account: kevin.account).count }.by(-1)
      expect(response).to have_http_status(200)
    end
  end
end
