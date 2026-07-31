# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /api/v1/accounts/:id' do
  describe 'endpoint behavior' do
    include_context 'with API authentication', oauth_scopes: 'read:accounts'

    context 'when logged out' do
      let(:account) { Fabricate(:account) }

      it 'returns account entity as 200 OK', :aggregate_failures do
        get "/api/v1/accounts/#{account.id}"

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:id]).to eq(account.id.to_s)
      end
    end

    context 'when the account does not exist' do
      it 'returns http not found' do
        get '/api/v1/accounts/1'

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:error]).to eq('Record not found')
      end
    end

    context 'when logged in' do
      subject do
        get "/api/v1/accounts/#{account.id}", headers: headers
      end

      let(:account) { Fabricate(:account) }

      it 'returns account entity as 200 OK', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:id]).to eq(account.id.to_s)
      end

      it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    end
  end

  describe 'response keys' do
    subject { get "/api/v1/accounts/#{account.id}" }

    shared_context 'with local account' do
      let(:account) { Fabricate(:account, username: 'alice') }
    end

    shared_context 'with remote account' do
      let(:account) { Fabricate(:remote_account, username: 'alice', domain: 'remote.example') }
    end

    describe 'acct' do
      context 'when local account' do
        include_context 'with local account'

        it 'returns the bare username' do
          subject
          expect(response.parsed_body[:acct]).to eq 'alice'
        end
      end

      context 'when remote account' do
        include_context 'with remote account'

        it 'returns username@domain' do
          subject
          expect(response.parsed_body[:acct]).to eq 'alice@remote.example'
        end
      end
    end

    describe 'url' do
      context 'when local account' do
        include_context 'with local account'

        it 'returns the public profile URL on the local domain', :aggregate_failures do
          subject
          url = URI.parse(response.parsed_body[:url])
          expect(url.scheme).to eq 'https'
          expect(url.host).to eq Rails.configuration.x.local_domain
          expect(url.path).to eq '/@alice'
        end
      end

      context 'when remote account' do
        include_context 'with remote account'

        it 'returns the URL preserved from the remote source', :aggregate_failures do
          subject
          url = URI.parse(response.parsed_body[:url])
          expect(url.scheme).to eq 'https'
          expect(url.host).to eq 'remote.example'
          expect(url.path).to eq '/users/alice'
        end
      end
    end

    describe 'uri' do
      context 'when local account' do
        include_context 'with local account'

        it 'returns the canonical ActivityPub URI on the local domain', :aggregate_failures do
          subject
          uri = URI.parse(response.parsed_body[:uri])
          expect(uri.scheme).to eq 'https'
          expect(uri.host).to eq Rails.configuration.x.local_domain
          expect(uri.path).to eq "/ap/users/#{account.id}"
        end
      end

      context 'when remote account' do
        include_context 'with remote account'

        it 'returns the ActivityPub URI preserved from the remote source', :aggregate_failures do
          subject
          uri = URI.parse(response.parsed_body[:uri])
          expect(uri.scheme).to eq 'https'
          expect(uri.host).to eq 'remote.example'
          expect(uri.path).to eq '/users/alice'
        end
      end
    end
  end
end
