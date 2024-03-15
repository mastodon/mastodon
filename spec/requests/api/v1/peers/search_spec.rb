# frozen_string_literal: true

require 'rails_helper'

describe 'API Peers Search' do
  describe 'GET /api/v1/peers/search' do
    context 'when peers api is disabled' do
      before do
        Setting.peers_api_enabled = false
      end

      it 'returns http not found response' do
        get '/api/v1/peers/search'

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'with no search param' do
      it 'returns http success and empty response' do
        get '/api/v1/peers/search'

        expect(response)
          .to have_http_status(200)
        expect(body_as_json)
          .to be_blank
      end
    end

    context 'with invalid search param' do
      it 'returns http success and empty response' do
        get '/api/v1/peers/search', params: { q: 'ftp://Invalid-Host!!.valüe' }

        expect(response)
          .to have_http_status(200)
        expect(body_as_json)
          .to be_blank
      end
    end

    context 'with search param' do
      let!(:account) { Fabricate(:account, domain: 'host.example') }

      before { Instance.refresh }

      it 'returns http success and json with known domains' do
        get '/api/v1/peers/search', params: { q: 'host.example' }

        expect(response)
          .to have_http_status(200)
        expect(body_as_json.size)
          .to eq(1)
        expect(body_as_json.first)
          .to eq(account.domain)
      end
    end
  end
end
