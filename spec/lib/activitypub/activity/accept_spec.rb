# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Accept do
  let(:sender)    { Fabricate(:account, domain: 'example.com') }
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

    context 'with a QuoteRequest' do
      let(:status) { Fabricate(:status, account: recipient) }
      let(:quoted_status) { Fabricate(:status, account: sender) }
      let(:quote) { Fabricate(:quote, status: status, quoted_status: quoted_status) }
      let(:approval_uri) { "https://#{sender.domain}/approvals/1" }

      let(:json) do
        {
          '@context': [
            'https://www.w3.org/ns/activitystreams',
            {
              QuoteRequest: 'https://w3id.org/fep/044f#QuoteRequest',
            },
          ],
          id: 'foo',
          type: 'Accept',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: {
            id: quote.activity_uri,
            type: 'QuoteRequest',
            actor: ActivityPub::TagManager.instance.uri_for(recipient),
            object: ActivityPub::TagManager.instance.uri_for(quoted_status),
            instrument: ActivityPub::TagManager.instance.uri_for(status),
          },
          result: approval_uri,
        }.with_indifferent_access
      end

      it 'marks the quote as approved and distribute an update' do
        expect { subject.perform }
          .to change { quote.reload.accepted? }.from(false).to(true)
          .and change { quote.reload.approval_uri }.to(approval_uri)
        expect(DistributionWorker)
          .to have_enqueued_sidekiq_job(status.id, { 'update' => true })
        expect(ActivityPub::StatusUpdateDistributionWorker)
          .to have_enqueued_sidekiq_job(status.id, { 'updated_at' => be_a(String) })
      end

      context 'when the quoted status is not from the sender of the Accept' do
        let(:quoted_status) { Fabricate(:status, account: Fabricate(:account, domain: 'example.com')) }

        it 'does not mark the quote as approved and does not distribute an update' do
          expect { subject.perform }
            .to not_change { quote.reload.accepted? }.from(false)
            .and not_change { quote.reload.approval_uri }.from(nil)
          expect(DistributionWorker)
            .to_not have_enqueued_sidekiq_job(status.id, { 'update' => true })
          expect(ActivityPub::StatusUpdateDistributionWorker)
            .to_not have_enqueued_sidekiq_job(status.id, anything)
        end
      end

      context 'when the quoting status is from an unrelated user' do
        let(:status) { Fabricate(:status, account: Fabricate(:account, domain: 'foobar.com')) }

        it 'does not mark the quote as approved and does not distribute an update' do
          expect { subject.perform }
            .to not_change { quote.reload.accepted? }.from(false)
            .and not_change { quote.reload.approval_uri }.from(nil)
          expect(DistributionWorker)
            .to_not have_enqueued_sidekiq_job(status.id, { 'update' => true })
          expect(ActivityPub::StatusUpdateDistributionWorker)
            .to_not have_enqueued_sidekiq_job(status.id, anything)
        end
      end

      context 'when approval_uri is missing' do
        let(:approval_uri) { nil }

        it 'does not mark the quote as approved and does not distribute an update' do
          expect { subject.perform }
            .to not_change { quote.reload.accepted? }.from(false)
            .and not_change { quote.reload.approval_uri }.from(nil)
          expect(DistributionWorker)
            .to_not have_enqueued_sidekiq_job(status.id, { 'update' => true })
          expect(ActivityPub::StatusUpdateDistributionWorker)
            .to_not have_enqueued_sidekiq_job(status.id, anything)
        end
      end

      context 'when the QuoteRequest is referenced by its identifier' do
        let(:json) do
          {
            '@context': [
              'https://www.w3.org/ns/activitystreams',
              {
                QuoteRequest: 'https://w3id.org/fep/044f#QuoteRequest',
              },
            ],
            id: 'foo',
            type: 'Accept',
            actor: ActivityPub::TagManager.instance.uri_for(sender),
            object: quote.activity_uri,
            result: approval_uri,
          }.with_indifferent_access
        end

        it 'marks the quote as approved and distribute an update' do
          expect { subject.perform }
            .to change { quote.reload.accepted? }.from(false).to(true)
            .and change { quote.reload.approval_uri }.to(approval_uri)
          expect(DistributionWorker)
            .to have_enqueued_sidekiq_job(status.id, { 'update' => true })
          expect(ActivityPub::StatusUpdateDistributionWorker)
            .to have_enqueued_sidekiq_job(status.id, { 'updated_at' => be_a(String) })
        end

        context 'when approval_uri is missing' do
          let(:approval_uri) { nil }

          it 'does not mark the quote as approved and does not distribute an update' do
            expect { subject.perform }
              .to not_change { quote.reload.accepted? }.from(false)
              .and not_change { quote.reload.approval_uri }.from(nil)
            expect(DistributionWorker)
              .to_not have_enqueued_sidekiq_job(status.id, { 'update' => true })
            expect(ActivityPub::StatusUpdateDistributionWorker)
              .to_not have_enqueued_sidekiq_job(status.id, anything)
          end
        end
      end
    end
  end
end
