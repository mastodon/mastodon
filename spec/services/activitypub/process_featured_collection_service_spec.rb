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

      expect(ActivityPub::ProcessFeaturedItemWorker).to have_enqueued_sidekiq_job.exactly(2).times
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
end
