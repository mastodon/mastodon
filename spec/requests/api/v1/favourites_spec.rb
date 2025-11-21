# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Favourites' do
  include_context 'with API authentication', oauth_scopes: 'read:favourites'

  describe 'GET /api/v1/favourites' do
    subject do
      get '/api/v1/favourites', headers: headers, params: params
    end

    let(:params)      { {} }
    let!(:favourites) { Fabricate.times(2, :favourite, account: user.account) }

    let(:expected_response) do
      favourites.map do |favourite|
        a_hash_including(id: favourite.status.id.to_s, account: a_hash_including(id: favourite.status.account.id.to_s))
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'write'

    it 'returns http success and includes the favourites' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of favourites and sets pagination headers' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
        expect(response)
          .to include_pagination_headers(
            prev: api_v1_favourites_url(limit: params[:limit], min_id: favourites.last.id),
            next: api_v1_favourites_url(limit: params[:limit], max_id: favourites.second.id)
          )
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
