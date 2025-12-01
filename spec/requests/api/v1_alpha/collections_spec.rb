# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1Alpha::Collections', feature: :collections do
  include_context 'with API authentication', oauth_scopes: 'read:collections write:collections'

  describe 'GET /api/v1_alpha/collections/:id' do
    subject do
      get "/api/v1_alpha/collections/#{collection.id}", headers: headers
    end

    let(:collection) { Fabricate(:collection) }
    let!(:items) { Fabricate.times(2, :collection_item, collection:) }

    shared_examples 'unfiltered, successful request' do
      it 'includes all items in the response' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body[:items].size).to eq 2
      end
    end

    context 'when user is not signed in' do
      let(:headers) { {} }

      it_behaves_like 'unfiltered, successful request'
    end

    context 'when user is signed in' do
      context 'when the user has not blocked or muted anyone' do
        it_behaves_like 'unfiltered, successful request'
      end

      context 'when the user has blocked an account' do
        before do
          user.account.block!(items.first.account)
        end

        it 'only includes the non-blocked account in the response' do
          subject

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:items].size).to eq 1
          expect(response.parsed_body[:items][0]['position']).to eq items.last.position
        end
      end
    end
  end

  describe 'POST /api/v1_alpha/collections' do
    subject do
      post '/api/v1_alpha/collections', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read'

    context 'with valid params' do
      let(:params) do
        {
          name: 'Low-traffic bots',
          description: 'Really nice bots, please follow',
          sensitive: '0',
          discoverable: '1',
        }
      end

      it 'creates a collection and returns http success' do
        expect do
          subject
        end.to change(Collection, :count).by(1)

        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid params' do
      it 'returns http unprocessable content and detailed errors' do
        expect do
          subject
        end.to_not change(Collection, :count)

        expect(response).to have_http_status(422)
        expect(response.parsed_body).to include({
          'error' => a_hash_including({
            'details' => a_hash_including({
              'name' => [{ 'error' => 'ERR_BLANK', 'description' => "can't be blank" }],
              'description' => [{ 'error' => 'ERR_BLANK', 'description' => "can't be blank" }],
            }),
          }),
        })
      end
    end
  end
end
