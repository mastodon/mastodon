# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::QuoteRequest do
  let(:sender)    { Fabricate(:account, domain: 'example.com') }
  let(:recipient) { Fabricate(:account) }
  let(:quoted_post) { Fabricate(:status, account: recipient) }
  let(:request_uri) { 'https://example.com/missing-ui' }
  let(:quoted_uri) { ActivityPub::TagManager.instance.uri_for(quoted_post) }
  let(:instrument) { 'https://example.com/unknown-status' }

  let(:json) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        {
          QuoteRequest: 'https://w3id.org/fep/044f#QuoteRequest',
        },
      ],
      id: request_uri,
      type: 'QuoteRequest',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: quoted_uri,
      instrument: instrument,
    }.deep_stringify_keys
  end

  let(:status_json) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        {
          '@id': 'https://w3id.org/fep/044f#quote',
          '@type': '@id',
        },
        {
          '@id': 'https://w3id.org/fep/044f#quoteAuthorization',
          '@type': '@id',
        },
      ],
      id: 'https://example.com/unknown-status',
      type: 'Note',
      summary: 'Show more',
      content: 'Hello universe',
      quote: ActivityPub::TagManager.instance.uri_for(quoted_post),
      attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
    }.deep_stringify_keys
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    context 'when trying to quote an unknown status' do
      let(:quoted_uri) { 'https://example.com/statuses/1234' }

      it 'does not send anything' do
        expect { subject.perform }
          .to_not enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
      end
    end

    context 'when trying to quote an unquotable local status' do
      it 'sends a Reject activity' do
        expect { subject.perform }
          .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(satisfying do |body|
            outgoing_json = Oj.load(body)
            outgoing_json['type'] == 'Reject' && %w(type id actor object instrument).all? { |key| json[key] == outgoing_json['object'][key] }
          end, recipient.id, sender.inbox_url)
      end
    end

    context 'when trying to quote an unquotable local status with an inlined instrument' do
      let(:instrument) { status_json.without('@context') }

      it 'sends a Reject activity' do
        expect { subject.perform }
          .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(satisfying do |body|
            outgoing_json = Oj.load(body)
            outgoing_json['type'] == 'Reject' && json['instrument']['id'] == outgoing_json['object']['instrument'] && %w(type id actor object).all? { |key| json[key] == outgoing_json['object'][key] }
          end, recipient.id, sender.inbox_url)
      end
    end

    context 'when trying to quote a quotable local status' do
      before do
        stub_request(:get, 'https://example.com/unknown-status').to_return(status: 200, body: Oj.dump(status_json), headers: { 'Content-Type': 'application/activity+json' })
        quoted_post.update(quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:public] << 16)
      end

      it 'accepts the quote and sends an Accept activity' do
        expect { subject.perform }
          .to change { quoted_post.reload.quotes.accepted.count }.by(1)
          .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(satisfying do |body|
            outgoing_json = Oj.load(body)
            outgoing_json['type'] == 'Accept' && %w(type id actor object instrument).all? { |key| json[key] == outgoing_json['object'][key] }
          end, recipient.id, sender.inbox_url)
      end
    end

    context 'when trying to quote a quotable local status with an inlined instrument' do
      let(:instrument) { status_json.without('@context') }

      before do
        quoted_post.update(quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:public] << 16)
      end

      it 'accepts the quote and sends an Accept activity' do
        expect { subject.perform }
          .to change { quoted_post.reload.quotes.accepted.count }.by(1)
          .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(satisfying do |body|
            outgoing_json = Oj.load(body)
            outgoing_json['type'] == 'Accept' && json['instrument']['id'] == outgoing_json['object']['instrument'] && %w(type id actor object).all? { |key| json[key] == outgoing_json['object'][key] }
          end, recipient.id, sender.inbox_url)
      end
    end
  end
end
