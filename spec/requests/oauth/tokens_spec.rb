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

  describe 'POST /oauth/token' do
    subject do
      post '/oauth/token', params: params
    end

    let(:user) { Fabricate(:user) }
    let(:application) { Fabricate(:application, scopes: 'read') }
    let(:token) { Fabricate(:accessible_access_token, application: application, resource_owner_id: user.id) }

    # TODO: Add tests for authorization_code grant flow

    context 'when using the client_credentials grant flow' do
      let(:params) do
        {
          grant_type: 'client_credentials',
          client_id: application.uid,
          client_secret: application.secret,
        }
      end

      it 'A refresh token is not issued per RFC 6749 section 4.4.3' do
        subject

        expect(response).to have_http_status(200)

        body = body_as_json

        expect(body[:access_token]).to be_present
        expect(body[:refresh_token]).to_not be_present

        new_token = Doorkeeper::AccessToken.last
        expect(new_token.resource_owner_id).to be_nil
      end
    end

    context 'when using the refresh_token grant flow' do
      let(:params) do
        {
          grant_type: 'refresh_token',
          client_id: application.uid,
          client_secret: application.secret,
          refresh_token: token.refresh_token,
        }
      end

      it 'successfully generates a new access token and revokes the previous one', :aggregate_failures do
        expect(token.revoked?).to be(false)

        subject

        expect(response).to have_http_status(200)

        # The request changes the token, so reload it before checking it's been
        # correctly revoked:
        expect(token.reload.revoked?).to be(true)

        body = body_as_json

        expect(body[:access_token]).to be_present
        expect(body[:refresh_token]).to be_present

        new_token = Doorkeeper::AccessToken.last
        expect(body[:access_token]).to eq(new_token.token)
        expect(body[:refresh_token]).to eq(new_token.refresh_token)

        # Ensure token properties carry across correctly:
        expect(new_token.scopes).to eq(token.scopes)
        expect(new_token.application_id).to be(token.application_id)
        expect(new_token.resource_owner_id).to be(token.resource_owner_id)
      end
    end
  end
end
