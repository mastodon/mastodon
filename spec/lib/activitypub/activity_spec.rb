# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity do
  describe 'processing a Create and an Update' do
    let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }
    let(:quoted_account) { Fabricate(:account, domain: 'quoted.example.com') }
    let(:quoted_status) { Fabricate(:status, account: quoted_account) }
    let(:approval_uri) { 'https://quoted.example.com/approvals/1' }

    let(:approval_payload) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
          {
            QuoteAuthorization: 'https://w3id.org/fep/044f#QuoteAuthorization',
            gts: 'https://gotosocial.org/ns#',
            interactingObject: {
              '@id': 'gts:interactingObject',
              '@type': '@id',
            },
            interactionTarget: {
              '@id': 'gts:interactionTarget',
              '@type': '@id',
            },
          },
        ],
        type: 'QuoteAuthorization',
        id: approval_uri,
        attributedTo: ActivityPub::TagManager.instance.uri_for(quoted_status.account),
        interactingObject: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
        interactionTarget: ActivityPub::TagManager.instance.uri_for(quoted_status),
      }
    end

    let(:publication_date) { 1.hour.ago.utc }

    let(:create_json) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
          {
            quote: 'https://w3id.org/fep/044f#quote',
          },
        ],
        id: [ActivityPub::TagManager.instance.uri_for(sender), '#create'].join,
        type: 'Create',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
          ],
          content: 'foo',
          published: publication_date.iso8601,
          quote: ActivityPub::TagManager.instance.uri_for(quoted_status),
        },
      }.deep_stringify_keys
    end

    let(:update_json) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
          {
            quote: 'https://w3id.org/fep/044f#quote',
            quoteAuthorization: { '@id': 'https://w3id.org/fep/044f#quoteAuthorization', '@type': '@id' },
          },
        ],
        id: [ActivityPub::TagManager.instance.uri_for(sender), '#update'].join,
        type: 'Update',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
          ],
          content: 'foo',
          published: publication_date.iso8601,
          quote: ActivityPub::TagManager.instance.uri_for(quoted_status),
          quoteAuthorization: approval_uri,
        },
      }.deep_stringify_keys
    end

    before do
      sender.update(uri: ActivityPub::TagManager.instance.uri_for(sender))

      stub_request(:get, approval_uri).to_return(headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump(approval_payload))
    end

    context 'when getting them in order' do
      it 'creates a status and approves the quote' do
        described_class.factory(create_json, sender).perform
        status = described_class.factory(update_json, sender).perform

        expect(status.quote.state).to eq 'accepted'
      end
    end

    context 'when getting them out of order' do
      it 'creates a status and approves the quote' do
        described_class.factory(update_json, sender).perform
        status = described_class.factory(create_json, sender).perform

        expect(status.quote.state).to eq 'accepted'
      end
    end
  end
end
