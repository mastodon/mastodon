# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::RepairRemoteCollectionsScheduler do
  include Redisable

  let(:worker) { described_class.new }

  describe 'perform' do
    let(:owner) do
      Fabricate(:remote_account, uri: 'https://example.com/accounts/123', collections_url: 'https://example.com/ap/users/123/featured_collections')
    end
    let(:other_account) do
      Fabricate(:remote_account, collections_url: 'https://example.com/ap/users/234/featured_collections')
    end
    let(:collection) do
      Fabricate(:remote_collection,
                uri: 'https://example.com/ap/users/123/collections/1',
                account: other_account,
                created_at: 2.hours.ago)
    end
    let(:response) do
      {
        '@context' => 'https://www.w3.org/ns/activitystreams',
        'id' => collection.uri,
        'type' => 'FeaturedCollection',
        'name' => collection.name,
        'summary' => collection.description_html,
        'attributedTo' => 'https://example.com/accounts/123',
        'sensitive' => false,
        'discoverable' => true,
        'totalItems' => 0,
      }
    end

    before do
      stub_request(:get, collection.uri)
        .to_return_json(
          status: 200,
          body: response,
          headers: { 'Content-Type' => 'application/activity+json' }
        )
    end

    after do
      redis.del('remote_collection_repair:last_known_good')
    end

    context 'without flag in redis set' do
      context 'when the proper account is known' do
        before { owner }

        it 'fixes the wrong attribution and sets the flag in redis' do
          worker.perform

          expect(collection.reload.account).to eq owner
          expect(redis.get('remote_collection_repair:last_known_good')).to_not be_nil
        end
      end

      context 'when the proper account is unknown' do
        let(:stubbed_service) { instance_double(ActivityPub::FetchRemoteAccountService) }

        before do
          allow(stubbed_service).to receive(:call).with('https://example.com/accounts/123') { service_result }
          allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(stubbed_service)
        end

        context 'when the service can fetch the account' do
          let(:service_result) { owner }

          it 'fixes the wrong attribution and sets the flag in redis' do
            worker.perform

            expect(collection.reload.account).to eq owner
            expect(redis.get('remote_collection_repair:last_known_good')).to_not be_nil
          end
        end

        context 'when the service cannot fetch the account' do
          let(:service_result) { nil }

          it 'does not fix the collection and does not set the flag in redis' do
            worker.perform

            expect(collection.reload.account).to eq other_account
            expect(redis.get('remote_collection_repair:last_known_good')).to be_nil
          end
        end
      end
    end

    context 'with flag in redis set' do
      before do
        redis.set('remote_collection_repair:last_known_good', collection.id + 1)
      end

      it 'does nothing with collections older than the last known good time' do
        worker.perform

        expect(collection.reload.account).to eq other_account
      end
    end
  end
end
