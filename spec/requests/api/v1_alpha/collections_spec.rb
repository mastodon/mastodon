# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1Alpha::Collections', feature: :collections do
  include_context 'with API authentication', oauth_scopes: 'read:collections write:collections'

  describe 'GET /api/v1_alpha/accounts/:account_id/collections' do
    subject do
      get "/api/v1_alpha/accounts/#{account.id}/collections", headers: headers, params: params
    end

    let(:params) { {} }

    let(:account) { Fabricate(:account) }

    before { Fabricate.times(3, :collection, account:) }

    it 'returns all collections for the given account and http success' do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body.size).to eq 3
    end

    context 'with limit param' do
      let(:params) { { limit: '1' } }

      it 'returns only a single result' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body.size).to eq 1

        expect(response)
          .to include_pagination_headers(
            next: api_v1_alpha_account_collections_url(account, limit: 1, offset: 1)
          )
      end
    end

    context 'with limit and offset params' do
      let(:params) { { limit: '1', offset: '1' } }

      it 'returns the correct result and headers' do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body.size).to eq 1

        expect(response)
          .to include_pagination_headers(
            prev: api_v1_alpha_account_collections_url(account, limit: 1, offset: 0),
            next: api_v1_alpha_account_collections_url(account, limit: 1, offset: 2)
          )
      end
    end
  end

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

  describe 'PATCH /api/v1_alpha/collections/:id' do
    subject do
      patch "/api/v1_alpha/collections/#{collection.id}", headers: headers, params: params
    end

    let(:collection) { Fabricate(:collection) }
    let(:params) { {} }

    context 'when user is not owner' do
      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end

    context 'when user is the owner' do
      let(:collection) do
        Fabricate(:collection,
                  account: user.account,
                  name: 'Pople to follow',
                  description: 'Cool pople',
                  sensitive: true,
                  discoverable: false)
      end

      it_behaves_like 'forbidden for wrong scope', 'read:collections'

      context 'with valid params' do
        let(:params) do
          {
            name: 'People to follow',
            description: 'Cool people',
            sensitive: '0',
            discoverable: '1',
          }
        end

        it 'updates the collection and returns http success' do
          subject
          collection.reload

          expect(response).to have_http_status(200)
          expect(collection.name).to eq 'People to follow'
          expect(collection.description).to eq 'Cool people'
          expect(collection.sensitive).to be false
          expect(collection.discoverable).to be true
        end
      end

      context 'with invalid params' do
        let(:params) { { name: '' } }

        it 'returns http unprocessable content and detailed errors' do
          subject

          expect(response).to have_http_status(422)
          expect(response.parsed_body).to include({
            'error' => a_hash_including({
              'details' => a_hash_including({
                'name' => [{ 'error' => 'ERR_BLANK', 'description' => "can't be blank" }],
              }),
            }),
          })
        end
      end
    end
  end

  describe 'DELETE /api/v1_alpha/collections/:id' do
    subject do
      delete "/api/v1_alpha/collections/#{collection.id}", headers: headers
    end

    let(:collection) { Fabricate(:collection) }

    context 'when user is not owner' do
      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end

    context 'when user is the owner' do
      let(:collection) { Fabricate(:collection, account: user.account) }

      it_behaves_like 'forbidden for wrong scope', 'read:collections'

      it 'deletes the collection and returns http success' do
        collection

        expect { subject }.to change(Collection, :count).by(-1)

        expect(response).to have_http_status(200)
      end
    end
  end
end
