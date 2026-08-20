# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub FeatureAuthorization endpoint' do
  describe 'GET /ap/accounts/:account_id/feature_authorizations/:collection_item_id' do
    let(:account) { Fabricate(:account) }
    let(:collection) { Fabricate(:collection) }
    let(:collection_item) { Fabricate(:collection_item, collection:, account:, state:) }

    context 'with an accepted collection item' do
      let(:state) { :accepted }

      it 'returns http success and activity json' do
        get ap_account_feature_authorization_path(account.id, collection_item)

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq 'application/activity+json'

        expect(response.parsed_body)
          .to include(type: 'FeatureAuthorization')
      end
    end

    shared_examples 'not found' do
      it 'returns http not found' do
        get ap_account_feature_authorization_path(collection.account_id, collection_item)

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'with a revoked collection item' do
      let(:state) { :revoked }

      it_behaves_like 'not found'
    end

    context 'with a collection item featuring a remote account' do
      let(:account) { Fabricate(:remote_account) }
      let(:state) { :accepted }

      it_behaves_like 'not found'
    end
  end
end
