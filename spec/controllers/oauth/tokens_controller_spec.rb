# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::TokensController, type: :controller do
  describe 'POST #revoke' do
    let!(:user) { Fabricate(:user) }
    let!(:access_token) { Fabricate(:accessible_access_token, resource_owner_id: user.id) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, user: user, access_token: access_token) }

    before do
      post :revoke, params: { token: access_token.token }
    end

    it 'revokes the token' do
      expect(access_token.reload.revoked_at).to_not be_nil
    end

    it 'removes web push subscription for token' do
      expect(Web::PushSubscription.where(access_token: access_token).count).to eq 0
    end
  end
end
