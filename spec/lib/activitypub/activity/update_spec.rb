# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Update do
  subject { described_class.new(json, sender) }

  let!(:sender) { Fabricate(:account, domain: 'example.com', inbox_url: 'https://example.com/foo/inbox', outbox_url: 'https://example.com/foo/outbox') }

  describe '#perform' do
    context 'with an Actor object' do
      let(:actor_json) do
        {
          '@context': [
            'https://www.w3.org/ns/activitystreams',
            'https://w3id.org/security/v1',
            {
              manuallyApprovesFollowers: 'as:manuallyApprovesFollowers',
              toot: 'http://joinmastodon.org/ns#',
              featured: { '@id': 'toot:featured', '@type': '@id' },
              featuredTags: { '@id': 'toot:featuredTags', '@type': '@id' },
            },
          ],
          id: sender.uri,
          type: 'Person',
          following: 'https://example.com/users/dfsdf/following',
          followers: 'https://example.com/users/dfsdf/followers',
          inbox: sender.inbox_url,
          outbox: sender.outbox_url,
          featured: 'https://example.com/users/dfsdf/featured',
          featuredTags: 'https://example.com/users/dfsdf/tags',
          preferredUsername: sender.username,
          name: 'Totally modified now',
          publicKey: {
            id: "#{sender.uri}#main-key",
            owner: sender.uri,
            publicKeyPem: sender.public_key,
          },
        }
      end

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: sender.uri,
          object: actor_json,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor_json[:outbox]).to_return(status: 404)
        stub_request(:get, actor_json[:followers]).to_return(status: 404)
        stub_request(:get, actor_json[:following]).to_return(status: 404)
        stub_request(:get, actor_json[:featured]).to_return(status: 404)
        stub_request(:get, actor_json[:featuredTags]).to_return(status: 404)

        subject.perform
      end

      it 'updates profile' do
        expect(sender.reload.display_name).to eq 'Totally modified now'
      end
    end

    context 'with a Question object' do
      let!(:at_time) { Time.now.utc }
      let!(:status) { Fabricate(:status, uri: 'https://example.com/statuses/poll', account: sender, poll: Poll.new(account: sender, options: %w(Bar Baz), cached_tallies: [0, 0], expires_at: at_time + 5.days)) }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: sender.uri,
          object: {
            type: 'Question',
            id: status.uri,
            content: 'Foo',
            endTime: (at_time + 5.days).iso8601,
            oneOf: [
              {
                type: 'Note',
                name: 'Bar',
                replies: {
                  type: 'Collection',
                  totalItems: 0,
                },
              },

              {
                type: 'Note',
                name: 'Baz',
                replies: {
                  type: 'Collection',
                  totalItems: 12,
                },
              },
            ],
          },
        }.with_indifferent_access
      end

      before do
        status.update!(uri: ActivityPub::TagManager.instance.uri_for(status))
        subject.perform
      end

      it 'updates poll numbers' do
        expect(status.preloadable_poll.cached_tallies).to eq [0, 12]
      end

      it 'does not set status as edited' do
        expect(status.edited_at).to be_nil
      end
    end
  end
end
