# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Accept do
  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }

  describe '#perform' do
    subject { described_class.new(json, sender) }

    context 'with a Follow request' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Accept',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: {
            id: 'https://abc-123/456',
            type: 'Follow',
            actor: ActivityPub::TagManager.instance.uri_for(recipient),
            object: ActivityPub::TagManager.instance.uri_for(sender),
          },
        }.deep_stringify_keys
      end

      context 'with a regular Follow' do
        before do
          Fabricate(:follow_request, account: recipient, target_account: sender)
        end

        it 'creates a follow relationship, removes the follow request, and queues a refresh' do
          expect { subject.perform }
            .to change { recipient.following?(sender) }.from(false).to(true)
            .and change { recipient.requested?(sender) }.from(true).to(false)

          expect(RemoteAccountRefreshWorker).to have_enqueued_sidekiq_job(sender.id)
        end
      end

      context 'when given a relay' do
        let!(:relay) { Fabricate(:relay, state: :pending, follow_activity_id: 'https://abc-123/456') }

        it 'marks the relay as accepted' do
          expect { subject.perform }
            .to change { relay.reload.accepted? }.from(false).to(true)
        end
      end
    end
  end
end
