# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAuth::Tokens' do
  # NOTE: these tests do cover some aspects of Doorkeeper which is tested
  # internally in doorkeeper, however, here we're testing that Doorkeeper is
  # working as we have configured it.

  describe 'POST /oauth/revoke' do
    subject do
      post '/oauth/revoke', params: params
    end

    let(:user) { Fabricate(:user) }
    let(:application) { Fabricate(:application, confidential: false) }
    let(:access_token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: application) }

    let(:params) do
      {
        token: access_token.token,
        # Optional, but good to have:
        token_type_hint: 'access_token',

        # Authentication as the client:
        client_id: application.uid,
        # We're using a public client (non-confidential), so don't have an
        # application secret:
        #
        # client_secret: application.secret,
      }
    end

    it 'revokes the token' do
      expect(access_token.revoked?).to be(false)
      expect(access_token.revoked_at).to be_nil

      subject

      access_token.reload

      expect(access_token.revoked?).to be(true)
      expect(access_token.revoked_at).to_not be_nil
    end

    it 'removes web push subscription for token' do
      Fabricate(:web_push_subscription, user: user, access_token: access_token)

      expect(Web::PushSubscription.where(access_token: access_token).count).to eq 1

      subject

      expect(Web::PushSubscription.where(access_token: access_token).count).to eq 0
    end
  end
end
