# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Reject do
  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Reject',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.deep_stringify_keys
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    context 'when rejecting a Follow' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Follow',
          actor: ActivityPub::TagManager.instance.uri_for(recipient),
          object: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      context 'when rejecting a pending follow request by target' do
        before do
          Fabricate(:follow_request, account: recipient, target_account: sender)
        end

        it 'removes the follow request without creating a follow relationship' do
          expect { subject.perform }
            .to change { recipient.requested?(sender) }.from(true).to(false)
            .and not_change { recipient.following?(sender) }.from(false)
        end
      end

      context 'when rejecting a pending follow request by uri' do
        before do
          Fabricate(:follow_request, account: recipient, target_account: sender, uri: 'bar')
        end

        it 'removes the follow request without creating a follow relationship' do
          expect { subject.perform }
            .to change { recipient.requested?(sender) }.from(true).to(false)
            .and not_change { recipient.following?(sender) }.from(false)
        end
      end

      context 'when rejecting a pending follow request by uri only' do
        let(:object_json) { 'bar' }

        before do
          Fabricate(:follow_request, account: recipient, target_account: sender, uri: 'bar')
        end

        it 'removes the follow request without creating a follow relationship' do
          expect { subject.perform }
            .to change { recipient.requested?(sender) }.from(true).to(false)
            .and not_change { recipient.following?(sender) }.from(false)
        end
      end

      context 'when rejecting an existing follow relationship by target' do
        before do
          Fabricate(:follow, account: recipient, target_account: sender)
        end

        it 'removes the follow relationship without creating a request' do
          expect { subject.perform }
            .to change { recipient.following?(sender) }.from(true).to(false)
            .and not_change { recipient.requested?(sender) }.from(false)
        end
      end

      context 'when rejecting an existing follow relationship by uri' do
        before do
          Fabricate(:follow, account: recipient, target_account: sender, uri: 'bar')
        end

        it 'removes the follow relationship without creating a request' do
          expect { subject.perform }
            .to change { recipient.following?(sender) }.from(true).to(false)
            .and not_change { recipient.requested?(sender) }.from(false)
        end
      end

      context 'when rejecting an existing follow relationship by uri only' do
        let(:object_json) { 'bar' }

        before do
          Fabricate(:follow, account: recipient, target_account: sender, uri: 'bar')
        end

        it 'removes the follow relationship without creating a request' do
          expect { subject.perform }
            .to change { recipient.following?(sender) }.from(true).to(false)
            .and not_change { recipient.requested?(sender) }.from(false)
        end
      end
    end

    context 'when given a relay' do
      subject { described_class.new(json, sender) }

      let!(:relay) { Fabricate(:relay, state: :pending, follow_activity_id: 'https://abc-123/456') }

      let(:object_json) do
        {
          id: 'https://abc-123/456',
          type: 'Follow',
          actor: ActivityPub::TagManager.instance.uri_for(recipient),
          object: ActivityPub::TagManager.instance.uri_for(sender),
        }.with_indifferent_access
      end

      it 'marks the relay as rejected' do
        subject.perform
        expect(relay.reload.rejected?).to be true
      end
    end

    context 'with a QuoteRequest' do
      let(:status) { Fabricate(:status, account: recipient) }
      let(:quoted_status) { Fabricate(:status, account: sender) }
      let(:quote) { Fabricate(:quote, status: status, quoted_status: quoted_status, activity_uri: 'https://abc-123/456') }
      let(:approval_uri) { "https://#{sender.domain}/approvals/1" }

      let(:object_json) do
        {
          id: 'https://abc-123/456',
          type: 'QuoteRequest',
          actor: ActivityPub::TagManager.instance.uri_for(recipient),
          object: ActivityPub::TagManager.instance.uri_for(quoted_status),
          instrument: ActivityPub::TagManager.instance.uri_for(status),
        }.with_indifferent_access
      end

      it 'marks the quote as rejected' do
        expect { subject.perform }
          .to change { quote.reload.rejected? }.from(false).to(true)
      end
    end
  end
end
