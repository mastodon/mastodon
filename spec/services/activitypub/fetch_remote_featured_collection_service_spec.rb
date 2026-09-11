# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteFeaturedCollectionService do
  subject { described_class.new }

  let(:account) { Fabricate(:remote_account) }
  let(:uri) { 'https://example.com/featured_collections/1' }
  let(:status) { 200 }
  let(:response) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => uri,
      'type' => 'FeaturedCollection',
      'name' => 'Incredible people',
      'summary' => 'These are really amazing',
      'attributedTo' => account.uri,
      'sensitive' => false,
      'discoverable' => true,
      'totalItems' => 0,
    }
  end

  before do
    stub_request(:get, uri)
      .to_return_json(
        status: status,
        body: response,
        headers: { 'Content-Type' => 'application/activity+json' }
      )
  end

  context 'when collection does not exist' do
    it 'creates a new collection' do
      collection = nil
      expect { collection = subject.call(uri) }.to change(Collection, :count).by(1)

      expect(collection.uri).to eq uri
      expect(collection.name).to eq 'Incredible people'
    end
  end

  context 'when collection already exists' do
    let!(:collection) do
      Fabricate(:remote_collection, account:, uri:, name: 'temp')
    end

    it 'returns the existing collection' do
      expect do
        expect(subject.call(uri)).to eq collection
      end.to_not change(Collection, :count)
    end
  end

  context 'when the URI can not be fetched' do
    let(:response) { nil }
    let(:status) { 404 }

    it 'returns `nil`' do
      expect(subject.call(uri)).to be_nil
    end
  end
end
