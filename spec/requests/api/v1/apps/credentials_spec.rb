# frozen_string_literal: true

require 'rails_helper'

describe 'Credentials' do
  describe 'GET /api/v1/apps/verify_credentials' do
    subject do
      get '/api/v1/apps/verify_credentials', headers: headers
    end

    context 'with an oauth token' do
      let(:application) { Fabricate(:application, scopes: 'read') }
      let(:token)   { Fabricate(:accessible_access_token, application: application) }
      let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

      it 'returns the app information correctly', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)

        expect(body_as_json).to match(
          a_hash_including(
            name: token.application.name,
            website: token.application.website,
            vapid_key: Rails.configuration.x.vapid_public_key,
            scopes: token.application.scopes.map(&:to_s),
            client_id: token.application.uid
          )
        )
      end
    end

    context 'with a non-read scoped oauth token' do
      let(:application) { Fabricate(:application, scopes: 'admin:write') }
      let(:token)   { Fabricate(:accessible_access_token, application: application) }
      let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'returns the app information correctly' do
        subject

        expect(body_as_json).to match(
          a_hash_including(
            name: token.application.name,
            website: token.application.website,
            vapid_key: Rails.configuration.x.vapid_public_key,
            scopes: token.application.scopes.map(&:to_s),
            client_id: token.application.uid
          )
        )
      end
    end

    context 'without an oauth token' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end

    context 'with a revoked oauth token' do
      let(:application) { Fabricate(:application, scopes: 'read') }
      let(:token)   { Fabricate(:accessible_access_token, application: application, revoked_at: DateTime.now.utc) }
      let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

      it 'returns http authorization error' do
        subject

        expect(response).to have_http_status(401)
      end

      it 'returns the error in the json response' do
        subject

        expect(body_as_json).to match(
          a_hash_including(
            error: 'The access token was revoked'
          )
        )
      end
    end

    context 'with an invalid oauth token' do
      let(:application) { Fabricate(:application, scopes: 'read') }
      let(:token)   { Fabricate(:accessible_access_token, application: application) }
      let(:headers) { { 'Authorization' => "Bearer #{token.token}-invalid" } }

      it 'returns http authorization error' do
        subject

        expect(response).to have_http_status(401)
      end

      it 'returns the error in the json response' do
        subject

        expect(body_as_json).to match(
          a_hash_including(
            error: 'The access token is invalid'
          )
        )
      end
    end
  end
end
