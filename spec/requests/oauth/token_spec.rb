# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing OAuth Tokens' do
  describe 'POST /oauth/token' do
    subject do
      post '/oauth/token', params: params
    end

    let(:application) do
      Fabricate(:application, scopes: 'read write follow', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    end
    let(:params) do
      {
        grant_type: grant_type,
        client_id: application.uid,
        client_secret: application.secret,
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        code: code,
        scope: scope,
      }
    end

    context "with grant_type 'authorization_code'" do
      let(:grant_type) { 'authorization_code' }
      let(:code) do
        access_grant = Fabricate(:access_grant, application: application, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', scopes: 'read write')
        access_grant.plaintext_token
      end

      shared_examples 'original scope request preservation' do
        it 'returns all scopes requested for the given code' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:scope]).to eq 'read write'
        end
      end

      context 'with no scopes specified' do
        let(:scope) { nil }

        it_behaves_like 'original scope request preservation'
      end

      context 'with scopes specified' do
        context 'when the scopes were requested for this code' do
          let(:scope) { 'write' }

          it_behaves_like 'original scope request preservation'
        end

        context 'when the scope was not requested for the code' do
          let(:scope) { 'follow' }

          it_behaves_like 'original scope request preservation'
        end

        context 'when the scope does not belong to the application' do
          let(:scope) { 'push' }

          it_behaves_like 'original scope request preservation'
        end
      end
    end

    context "with grant_type 'client_credentials'" do
      let(:grant_type) { 'client_credentials' }
      let(:code) { nil }

      context 'with no scopes specified' do
        let(:scope) { nil }

        it 'returns only the default scope' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:scope]).to eq('read')
        end
      end

      context 'with scopes specified' do
        context 'when the scopes belong to the application' do
          let(:scope) { 'read write' }

          it 'returns all the requested scopes' do
            subject

            expect(response).to have_http_status(200)
            expect(response.parsed_body[:scope]).to eq 'read write'
          end
        end

        context 'when some scopes do not belong to the application' do
          let(:scope) { 'read write push' }

          it 'returns an error' do
            subject

            expect(response).to have_http_status(400)
          end
        end
      end
    end
  end

  describe 'POST /oauth/revoke' do
    subject { post '/oauth/revoke', params: { client_id: application.uid, token: access_token.token } }

    let!(:user) { Fabricate(:user) }
    let!(:application) { Fabricate(:application, confidential: false) }
    let!(:access_token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: application) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, user: user, access_token: access_token) }

    it 'revokes the token and removes subscriptions' do
      expect { subject }
        .to change { access_token.reload.revoked_at }.from(nil).to(be_present)

      expect(Web::PushSubscription.where(access_token: access_token).count)
        .to eq(0)
      expect { web_push_subscription.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
