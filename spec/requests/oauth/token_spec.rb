# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Obtaining OAuth Tokens' do
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

      shared_examples 'returns originally requested scopes' do
        it 'returns all scopes requested for the given code' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:scope]).to eq 'read write'
        end
      end

      context 'with no scopes specified' do
        let(:scope) { nil }

        include_examples 'returns originally requested scopes'
      end

      context 'with scopes specified' do
        context 'when the scopes were requested for this code' do
          let(:scope) { 'write' }

          include_examples 'returns originally requested scopes'
        end

        context 'when the scope was not requested for the code' do
          let(:scope) { 'follow' }

          include_examples 'returns originally requested scopes'
        end

        context 'when the scope does not belong to the application' do
          let(:scope) { 'push' }

          include_examples 'returns originally requested scopes'
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
end
