# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Redirect page for collections' do
  describe 'GET /redirect/collections/:id' do
    context 'with a remote collection' do
      let(:collection) { Fabricate :remote_collection }

      it 'renders a page with link to resource' do
        get redirect_collection_path(id: collection.id)

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to have_link(ActivityPub::TagManager.instance.url_for(collection))
      end

      context 'with json format' do
        it 'renders not found' do
          get redirect_collection_path(id: collection.id, format: :json)

          expect(response)
            .to have_http_status(404)
        end
      end
    end

    context 'with a local collection' do
      let(:collection) { Fabricate :collection, local: true }

      it 'renders not found' do
        get redirect_collection_path(id: collection.id)

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'with a remote collection owned by a suspended account' do
      let(:collection) { Fabricate :remote_collection }

      before { collection.account.suspend! }

      it 'renders not found' do
        get redirect_collection_path(id: collection.id)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
