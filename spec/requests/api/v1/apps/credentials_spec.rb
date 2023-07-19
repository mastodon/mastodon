# frozen_string_literal: true

require 'rails_helper'

describe 'Credentials' do
  describe 'GET /api/v1/apps/verify_credentials' do
    subject do
      get '/api/v1/apps/verify_credentials', headers: headers
    end

    context 'with an oauth token' do
      let(:token)   { Fabricate(:accessible_access_token, scopes: 'read', application: Fabricate(:application)) }
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
            vapid_key: Rails.configuration.x.vapid_public_key
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
  end
end
