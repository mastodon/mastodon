# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::QuoteRequest do
  let(:sender)    { Fabricate(:account, domain: 'example.com') }
  let(:recipient) { Fabricate(:account) }
  let(:quoted_post) { Fabricate(:status, account: recipient) }
  let(:request_uri) { 'https://example.com/missing-ui' }
  let(:quoted_uri) { ActivityPub::TagManager.instance.uri_for(quoted_post) }

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
      instrument: 'https://example.com/unknown-status',
    }.with_indifferent_access
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
  end
end
