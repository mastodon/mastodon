# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::FeatureRequest do
  let(:sender)    { Fabricate(:remote_account) }
  let(:recipient) { Fabricate(:account, discoverable:) }
  let(:collection) { Fabricate(:remote_collection, account: sender) }

  let(:json) do
    {
      '@context' => [
        'https://www.w3.org/ns/activitystreams',
      ],
      'id' => 'https://example.com/feature_requests/1',
      'type' => 'FeatureRequest',
      'actor' => sender.uri,
      'object' => ActivityPub::TagManager.instance.uri_for(recipient),
      'instrument' => collection.uri,
    }
  end

  describe '#perform', feature: :collections do
    subject { described_class.new(json, sender) }

    context 'when recipient is discoverable' do
      let(:discoverable) { true }

      it 'schedules a job to send an `Accept` activity as well as a notification worker' do
        expect { subject.perform }
          .to enqueue_sidekiq_job(LocalNotificationWorker).with(recipient.id, anything, 'CollectionItem', 'added_to_collection')
          .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(satisfying do |body|
            response_json = JSON.parse(body)
            response_json['type'] == 'Accept' &&
              response_json['object'] == 'https://example.com/feature_requests/1' &&
              response_json['to'] == sender.uri
          end, recipient.id, sender.inbox_url)
      end
    end

    context 'when recipient is not discoverable' do
      let(:discoverable) { false }

      it 'schedules a job to send a `Reject` activity' do
        expect { subject.perform }
          .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(satisfying do |body|
            response_json = JSON.parse(body)
            response_json['type'] == 'Reject' &&
              response_json['object'] == 'https://example.com/feature_requests/1' &&
              response_json['to'] == sender.uri
          end, recipient.id, sender.inbox_url)
      end
    end

    context 'when the collection is not yet known' do
      let(:discoverable) { true }
      let(:collection) { instance_double(Collection, uri: 'https://example.com/collections/1') }
      let(:stubbed_service) do
        service = instance_double(ActivityPub::FetchRemoteFeaturedCollectionService)
        allow(service).to receive(:call) do
          Fabricate(:remote_collection, account: sender, uri: collection.uri)
        end
        service
      end

      before do
        allow(ActivityPub::FetchRemoteFeaturedCollectionService).to receive(:new).and_return(stubbed_service)
      end

      it 'fetches the collection before handling the request' do
        subject.perform

        expect(ActivityPub::DeliveryWorker).to have_enqueued_sidekiq_job
        expect(stubbed_service).to have_received(:call)
      end
    end
  end
end
