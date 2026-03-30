# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessFeaturedCollectionService do
  subject { described_class.new }

  let(:account) { Fabricate(:remote_account) }
  let(:summary) { '<p>A list of remote actors you should follow.</p>' }
  let(:base_json) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => 'https://example.com/featured_collections/1',
      'type' => 'FeaturedCollection',
      'attributedTo' => account.uri,
      'name' => 'Good people from other servers',
      'sensitive' => false,
      'discoverable' => true,
      'topic' => {
        'type' => 'Hashtag',
        'name' => '#people',
      },
      'published' => '2026-03-09T15:19:25Z',
      'totalItems' => 2,
      'orderedItems' => [
        'https://example.com/featured_items/1',
        'https://example.com/featured_items/2',
      ],
    }
  end
  let(:featured_collection_json) { base_json.merge('summary' => summary) }

  context "when the collection's URI does not match the account's" do
    let(:non_matching_account) { Fabricate(:remote_account, domain: 'other.example.com') }

    it 'does not create a collection and returns `nil`' do
      expect do
        expect(subject.call(non_matching_account, featured_collection_json)).to be_nil
      end.to_not change(Collection, :count)
    end
  end

  context 'when URIs match up' do
    it 'creates a collection and queues jobs to handle its items' do
      expect { subject.call(account, featured_collection_json) }.to change(account.collections, :count).by(1)

      new_collection = account.collections.last
      expect(new_collection.uri).to eq 'https://example.com/featured_collections/1'
      expect(new_collection.name).to eq 'Good people from other servers'
      expect(new_collection.description_html).to eq '<p>A list of remote actors you should follow.</p>'
      expect(new_collection.sensitive).to be false
      expect(new_collection.discoverable).to be true
      expect(new_collection.tag.formatted_name).to eq '#people'

      expect(ActivityPub::ProcessFeaturedItemWorker).to have_enqueued_sidekiq_job.with(new_collection.id, 'https://example.com/featured_items/1', 1, nil)
      expect(ActivityPub::ProcessFeaturedItemWorker).to have_enqueued_sidekiq_job.with(new_collection.id, 'https://example.com/featured_items/2', 2, nil)
    end
  end

  context 'when the json includes a summary map' do
    let(:featured_collection_json) do
      base_json.merge({
        'summaryMap' => {
          'en' => summary,
        },
      })
    end

    it 'sets language and summary correctly' do
      expect { subject.call(account, featured_collection_json) }.to change(account.collections, :count).by(1)

      new_collection = account.collections.last
      expect(new_collection.language).to eq 'en'
      expect(new_collection.description_html).to eq '<p>A list of remote actors you should follow.</p>'
    end
  end

  context 'when the collection already exists' do
    let(:collection) { Fabricate(:remote_collection, account:, uri: base_json['id'], name: 'placeholder') }

    before do
      Fabricate(:collection_item, collection:, uri: 'https://example.com/featured_items/1')
      Fabricate(:collection_item, collection:, uri: 'https://example.com/featured_items/3')
    end

    it 'updates the existing collection, removes the item that no longer exists and queues a jobs to fetch the other items' do
      expect { subject.call(account, featured_collection_json) }
        .to change(collection.collection_items, :count).by(-1)

      expect(collection.reload.name).to eq 'Good people from other servers'
      expect(ActivityPub::ProcessFeaturedItemWorker).to have_enqueued_sidekiq_job.exactly(2).times
    end

    context 'when the updated collection no longer contains any items' do
      let(:featured_collection_json) do
        base_json.merge({
          'summary' => summary,
          'totalItems' => 0,
          'orderedItems' => nil,
        })
      end

      it 'removes all items' do
        expect { subject.call(account, featured_collection_json) }
          .to change(collection.collection_items, :count).by(-2)
      end
    end
  end
end
