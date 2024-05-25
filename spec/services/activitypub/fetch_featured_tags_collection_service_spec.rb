# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchFeaturedTagsCollectionService, type: :service do
  subject { described_class.new }

  let(:collection_url) { 'https://example.com/account/tags' }
  let(:actor) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/account') }

  let(:items) do
    [
      { type: 'Hashtag', href: 'https://example.com/account/tagged/foo', name: 'Foo' },
      { type: 'Hashtag', href: 'https://example.com/account/tagged/bar', name: 'bar' },
      { type: 'Hashtag', href: 'https://example.com/account/tagged/baz', name: 'baZ' },
    ]
  end

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Collection',
      id: collection_url,
      items: items,
    }.with_indifferent_access
  end

  shared_examples 'sets featured tags' do
    before do
      subject.call(actor, collection_url)
    end

    it 'sets expected tags as pinned tags' do
      expect(actor.featured_tags.map(&:display_name)).to match_array %w(Foo bar baZ)
    end
  end

  describe '#call' do
    context 'when the endpoint is a Collection' do
      before do
        stub_request(:get, collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'sets featured tags'
    end

    context 'when the account already has featured tags' do
      before do
        stub_request(:get, collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })

        actor.featured_tags.create!(name: 'FoO')
        actor.featured_tags.create!(name: 'baz')
        actor.featured_tags.create!(name: 'oh').update(name: nil)
      end

      it_behaves_like 'sets featured tags'
    end

    context 'when the endpoint is an OrderedCollection' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'OrderedCollection',
          id: collection_url,
          orderedItems: items,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'sets featured tags'
    end

    context 'when the endpoint is a paginated Collection' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'Collection',
          id: collection_url,
          first: {
            type: 'CollectionPage',
            partOf: collection_url,
            items: items,
          },
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'sets featured tags'
    end
  end
end
