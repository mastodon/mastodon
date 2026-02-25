# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1Alpha::CollectionItems', feature: :collections do
  include_context 'with API authentication', oauth_scopes: 'read:collections write:collections'

  describe 'POST /api/v1_alpha/collections/:collection_id/items' do
    subject do
      post "/api/v1_alpha/collections/#{collection.id}/items", headers: headers, params: params
    end

    let(:collection) { Fabricate(:collection, account: user.account) }
    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read'

    context 'when user is owner of the collection' do
      context 'with valid params' do
        let(:other_account) { Fabricate(:account) }
        let(:params) { { account_id: other_account.id } }

        it 'creates a collection item and returns http success' do
          expect do
            subject
          end.to change(collection.collection_items, :count).by(1)

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to have_key('collection_item')
        end
      end

      context 'with invalid params' do
        it 'returns http unprocessable content' do
          expect do
            subject
          end.to_not change(CollectionItem, :count)

          expect(response).to have_http_status(422)
        end
      end
    end

    context 'when user is not the owner of the collection' do
      let(:collection) { Fabricate(:collection) }
      let(:other_account) { Fabricate(:account) }
      let(:params) { { account_id: other_account.id } }

      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'DELETE /api/v1_alpha/collections/:collection_id/items/:id' do
    subject do
      delete "/api/v1_alpha/collections/#{collection.id}/items/#{item.id}", headers: headers
    end

    let(:collection) { Fabricate(:collection, account: user.account) }
    let(:item) { Fabricate(:collection_item, collection:) }

    it_behaves_like 'forbidden for wrong scope', 'read'

    context 'when user is owner of the collection' do
      context 'when item belongs to collection' do
        it 'deletes the collection item and returns http success' do
          item # Make sure this exists before calling the API

          expect do
            subject
          end.to change(collection.collection_items, :count).by(-1)

          expect(response).to have_http_status(200)
        end
      end

      context 'when item does not belong to to collection' do
        let(:item) { Fabricate(:collection_item) }

        it 'returns http not found' do
          item # Make sure this exists before calling the API

          expect do
            subject
          end.to_not change(CollectionItem, :count)

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'when user is not the owner of the collection' do
      let(:collection) { Fabricate(:collection) }

      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end
  end
end
