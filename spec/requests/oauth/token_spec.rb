# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing OAuth Tokens' do
  describe 'POST /oauth/token' do
    subject do
      post '/oauth/token', params: params.merge(additional_params), headers: headers
    end

    let(:headers) { nil }
    let(:additional_params) { {} }
    let(:params) { {} }

    let(:application) do
      Fabricate(:application, scopes: 'read write follow', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    end

    context "with grant_type 'authorization_code'" do
      let(:access_grant) { Fabricate(:access_grant, application: application, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', scopes: 'read write') }
      let(:access_grant_scopes) { access_grant.scopes.to_s }
      let(:code) { access_grant.plaintext_token }

      shared_examples 'returns a correctly scoped access token' do
        it 'returns the scopes requested by the authorization code' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:scope]).to eq access_grant_scopes
        end

        context 'with additional parameters not used by the grant type' do
          # When performing an authorization code grant flow, the `/oauth/token`
          # endpoint does not accept a `scope` parameter, and should not
          # override the scopes from the authorization grant.
          let(:additional_params) do
            {
              scope: 'write',
            }
          end

          it 'returns the scopes requested by the authorization code' do
            subject

            expect(response).to have_http_status(200)
            expect(response.parsed_body[:scope]).to eq access_grant_scopes
          end
        end
      end

      context 'with client authentication via params' do
        let(:headers) { nil }
        let(:params) do
          {
            grant_type: 'authorization_code',
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
            client_id: application.uid,
            client_secret: application.secret,
            code: code,
          }
        end

        it_behaves_like 'returns a correctly scoped access token'
      end

      context 'with client authentication via basic auth' do
        let(:headers) do
          {
            Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(application.uid, application.secret),
          }
        end

        let(:params) do
          {
            grant_type: 'authorization_code',
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
            code: code,
          }
        end

        it_behaves_like 'returns a correctly scoped access token'
      end
    end

    context "with grant_type 'client_credentials'" do
      shared_examples 'returns the correct scopes' do
        context 'with no scopes specified' do
          let(:scope) { nil }

          it 'returns only the authorization server default scope (read)' do
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
              expect(response.parsed_body[:error]).to eq 'invalid_scope'
            end
          end
        end
      end

      context 'with client authentication via basic auth' do
        let(:headers) do
          {
            Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(application.uid, application.secret),
          }
        end

        let(:params) do
          {
            grant_type: 'client_credentials',
            scope: scope,
          }
        end

        it_behaves_like 'returns the correct scopes'
      end

      context 'with client authentication via params' do
        let(:headers) { nil }
        let(:params) do
          {
            grant_type: 'client_credentials',
            client_id: application.uid,
            client_secret: application.secret,
            scope: scope,
          }
        end

        it_behaves_like 'returns the correct scopes'
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
