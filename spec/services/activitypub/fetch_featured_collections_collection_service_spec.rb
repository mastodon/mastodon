# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchFeaturedCollectionsCollectionService do
  subject { described_class.new }

  let(:account) { Fabricate(:remote_account, collections_url: 'https://example.com/account/featured_collections') }
  let(:featured_collection_one) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => 'https://example.com/featured_collections/1',
      'type' => 'FeaturedCollection',
      'name' => 'Incredible people',
      'summary' => 'These are really amazing',
      'attributedTo' => account.uri,
      'sensitive' => false,
      'discoverable' => true,
      'totalItems' => 0,
    }
  end
  let(:featured_collection_two) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => 'https://example.com/featured_collections/2',
      'type' => 'FeaturedCollection',
      'name' => 'Even cooler people',
      'summary' => 'These are just as amazing',
      'attributedTo' => account.uri,
      'sensitive' => false,
      'discoverable' => true,
      'totalItems' => 0,
    }
  end
  let(:items) { [featured_collection_one, featured_collection_two] }
  let(:collection_json) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'type' => 'Collection',
      'id' => account.collections_url,
      'items' => items,
    }
  end

  describe '#call' do
    subject { described_class.new.call(account) }

    before do
      stub_request(:get, account.collections_url)
        .to_return_json(status: 200, body: collection_json, headers: { 'Content-Type': 'application/activity+json' })
    end

    shared_examples 'collection creation' do
      it 'creates the expected collections' do
        expect { subject }.to change(account.collections, :count).by(2)
        expect(account.collections.pluck(:name)).to contain_exactly('Incredible people', 'Even cooler people')
      end
    end

    context 'when the endpoint is not paginated' do
      context 'when all items are inlined' do
        it_behaves_like 'collection creation'
      end

      context 'when items are URIs' do
        let(:items) { [featured_collection_one['id'], featured_collection_two['id']] }

        before do
          [featured_collection_one, featured_collection_two].each do |featured_collection|
            stub_request(:get, featured_collection['id'])
              .to_return_json(status: 200, body: featured_collection, headers: { 'Content-Type': 'application/activity+json' })
          end
        end

        it_behaves_like 'collection creation'
      end
    end

    context 'when the endpoint is a paginated Collection' do
      let(:first_page) do
        {
          '@context' => 'https://www.w3.org/ns/activitystreams',
          'type' => 'CollectionPage',
          'partOf' => account.collections_url,
          'id' => 'https://example.com/featured_collections/1/1',
          'items' => [featured_collection_one],
          'next' => second_page['id'],
        }
      end
      let(:second_page) do
        {
          '@context' => 'https://www.w3.org/ns/activitystreams',
          'type' => 'CollectionPage',
          'partOf' => account.collections_url,
          'id' => 'https://example.com/featured_collections/1/2',
          'items' => [featured_collection_two],
        }
      end
      let(:collection_json) do
        {
          '@context' => 'https://www.w3.org/ns/activitystreams',
          'type' => 'Collection',
          'id' => account.collections_url,
          'first' => first_page['id'],
        }
      end

      before do
        [first_page, second_page].each do |page|
          stub_request(:get, page['id'])
            .to_return_json(status: 200, body: page, headers: { 'Content-Type': 'application/activity+json' })
        end
      end

      it_behaves_like 'collection creation'
    end
  end
end
