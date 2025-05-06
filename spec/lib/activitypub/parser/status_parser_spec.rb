# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Parser::StatusParser do
  subject { described_class.new(json) }

  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }
  let(:follower) { Fabricate(:account, username: 'bob') }
  let(:context) { 'https://www.w3.org/ns/activitystreams' }

  let(:json) do
    {
      '@context': context,
      id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.deep_stringify_keys
  end

  let(:object_json) do
    {
      id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
      type: 'Note',
      to: [
        'https://www.w3.org/ns/activitystreams#Public',
        ActivityPub::TagManager.instance.uri_for(follower),
      ],
      content: '@bob lorem ipsum',
      contentMap: {
        EN: '@bob lorem ipsum',
      },
      published: 1.hour.ago.utc.iso8601,
      updated: 1.hour.ago.utc.iso8601,
      tag: {
        type: 'Mention',
        href: ActivityPub::TagManager.instance.uri_for(follower),
      },
    }
  end

  it 'correctly parses status' do
    expect(subject).to have_attributes(
      text: '@bob lorem ipsum',
      uri: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
      reply: false,
      language: :en
    )
  end

  context 'when the likes collection is not inlined' do
    let(:object_json) do
      {
        id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
        type: 'Note',
        to: 'https://www.w3.org/ns/activitystreams#Public',
        content: 'bleh',
        published: 1.hour.ago.utc.iso8601,
        updated: 1.hour.ago.utc.iso8601,
        likes: 'https://example.com/collections/likes',
      }
    end

    it 'does not raise an error' do
      expect { subject.favourites_count }.to_not raise_error
    end
  end

  describe '#quote_policy' do
    subject do
      described_class
        .new(
          json,
          actor_uri: ActivityPub::TagManager.instance.uri_for(sender),
          followers_collection: sender.followers_url
        ).quote_policy
    end

    let(:context) do
      [
        'https://www.w3.org/ns/activitystreams',
        {
          gts: 'https://gotosocial.org/ns#',
          interactionPolicy: {
            '@id': 'gts:interactionPolicy',
            '@type': '@id',
          },
          canQuote: {
            '@id': 'gts:canQuote',
            '@type': '@id',
          },
          automaticApproval: {
            '@id': 'gts:automaticApproval',
            '@type': '@id',
          },
          manualApproval: {
            '@id': 'gts:manualApproval',
            '@type': '@id',
          },
        },
      ]
    end

    context 'when nobody is allowed to quote' do
      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
            ActivityPub::TagManager.instance.uri_for(follower),
          ],
          interactionPolicy: {
            canQuote: {
              automaticApproval: ActivityPub::TagManager.instance.uri_for(sender),
            },
          },
          content: 'bleh',
          published: 1.hour.ago.utc.iso8601,
          updated: 1.hour.ago.utc.iso8601,
        }
      end

      it 'returns a policy not allowing anyone to quote' do
        expect(subject).to eq 0
      end
    end

    context 'when everybody is allowed to quote' do
      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
            ActivityPub::TagManager.instance.uri_for(follower),
          ],
          interactionPolicy: {
            canQuote: {
              automaticApproval: 'https://www.w3.org/ns/activitystreams#Public',
            },
          },
          content: 'bleh',
          published: 1.hour.ago.utc.iso8601,
          updated: 1.hour.ago.utc.iso8601,
        }
      end

      it 'returns a policy not allowing anyone to quote' do
        expect(subject).to eq(Status::QUOTE_APPROVAL_POLICY_FLAGS[:public] << 16)
      end
    end

    context 'when everybody is allowed to quote but only followers are automatically approved' do
      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
            ActivityPub::TagManager.instance.uri_for(follower),
          ],
          interactionPolicy: {
            canQuote: {
              automaticApproval: sender.followers_url,
              manualApproval: 'https://www.w3.org/ns/activitystreams#Public',
            },
          },
          content: 'bleh',
          published: 1.hour.ago.utc.iso8601,
          updated: 1.hour.ago.utc.iso8601,
        }
      end

      it 'returns a policy allowing everyone including followers' do
        expect(subject).to eq Status::QUOTE_APPROVAL_POLICY_FLAGS[:public] | (Status::QUOTE_APPROVAL_POLICY_FLAGS[:followers] << 16)
      end
    end
  end
end
