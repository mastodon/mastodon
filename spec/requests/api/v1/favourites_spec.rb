# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Favourites' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:favourites' }
  let(:headers) { { Authorization: "Bearer #{token.token}" } }

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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the favourites' do
      subject

      expect(response.parsed_body).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of favourites' do
        subject

        expect(response.parsed_body.size).to eq(params[:limit])
      end

      it 'sets the correct pagination headers' do
        subject

        expect(response)
          .to include_pagination_headers(
            prev: api_v1_favourites_url(limit: params[:limit], min_id: favourites.last.id),
            next: api_v1_favourites_url(limit: params[:limit], max_id: favourites.second.id)
          )
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end
end
