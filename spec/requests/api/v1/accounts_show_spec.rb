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
end
