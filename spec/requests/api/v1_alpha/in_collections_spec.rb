# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1Alpha::InCollections', feature: :collections do
  include_context 'with API authentication', oauth_scopes: 'read:collections write:collections'

  describe 'GET /api/v1_alpha/in_collections' do
    subject do
      get '/api/v1_alpha/in_collections', headers: headers, params: params
    end

    let(:params) { {} }

    before { Fabricate.times(3, :collection_item, account: user.account) }

    it 'returns all collections for the given account and http success' do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body[:collections].size).to eq 3
    end

    context 'with limit param' do
      let(:params) { { limit: '1' } }

      it 'returns only a single result' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body[:collections].size).to eq 1

        expect(response)
          .to include_pagination_headers(
            next: api_v1_alpha_in_collections_url(limit: 1, offset: 1)
          )
      end
    end

    context 'with limit and offset params' do
      let(:params) { { limit: '1', offset: '1' } }

      it 'returns the correct result and headers' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body[:collections].size).to eq 1

        expect(response)
          .to include_pagination_headers(
            prev: api_v1_alpha_in_collections_url(limit: 1, offset: 0),
            next: api_v1_alpha_in_collections_url(limit: 1, offset: 2)
          )
      end
    end
  end
end
