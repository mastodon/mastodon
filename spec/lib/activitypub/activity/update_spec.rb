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

    context 'with a Note object' do
      let(:updated) { nil }
      let(:favourites) { 50 }
      let(:reblogs) { 100 }

      let!(:status) { Fabricate(:status, uri: 'https://example.com/statuses/poll', account: sender) }
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: sender.uri,
          object: {
            type: 'Note',
            id: status.uri,
            content: 'Foo',
            updated: updated,
            likes: {
              id: "#{status.uri}/likes",
              type: 'Collection',
              totalItems: favourites,
            },
            shares: {
              id: "#{status.uri}/shares",
              type: 'Collection',
              totalItems: reblogs,
            },
          },
        }.with_indifferent_access
      end

      shared_examples 'updates counts' do
        it 'updates the reblog count' do
          expect { subject.perform }.to change { status.reload.untrusted_reblogs_count }.to(reblogs)
        end

        it 'updates the favourites count' do
          expect { subject.perform }.to change { status.reload.untrusted_favourites_count }.to(favourites)
        end
      end

      context 'with an implicit update' do
        before do
          status.update!(uri: ActivityPub::TagManager.instance.uri_for(status))
        end

        it_behaves_like 'updates counts'
      end

      context 'with an explicit update' do
        let(:favourites) { 150 }
        let(:reblogs) { 200 }
        let(:updated) { Time.now.utc.iso8601 }

        before do
          status.update!(uri: ActivityPub::TagManager.instance.uri_for(status))
        end

        it_behaves_like 'updates counts'
      end
    end

    context 'with an Article object' do
      let(:updated) { nil }
      let(:favourites) { 50 }
      let(:reblogs) { 100 }

      let!(:status) do
        Fabricate(
          :status,
          uri: 'https://example.com/statuses/article',
          account: sender,
          text: "<h2>Future of the Fediverse</h2>\n\n<p>Guest article by John Mastodon</p><p>The fediverse is great reading this you will find out why!</p>"
        )
      end

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: sender.uri,
          object: {
            type: 'Article',
            id: status.uri,
            name: 'Future of the Fediverse',
            summary: '<p>Guest article by Jane Mastodon</p><p>The fediverse is great reading this you will find out why!</p>',
            content: 'Foo',
            updated: updated,
            likes: {
              id: "#{status.uri}/likes",
              type: 'Collection',
              totalItems: favourites,
            },
            shares: {
              id: "#{status.uri}/shares",
              type: 'Collection',
              totalItems: reblogs,
            },
          },
        }.with_indifferent_access
      end

      shared_examples 'updates counts' do
        it 'updates the reblog count' do
          expect { subject.perform }.to change { status.reload.untrusted_reblogs_count }.to(reblogs)
        end

        it 'updates the favourites count' do
          expect { subject.perform }.to change { status.reload.untrusted_favourites_count }.to(favourites)
        end
      end

      context 'with an implicit update' do
        before do
          status.update!(uri: ActivityPub::TagManager.instance.uri_for(status))
        end

        it_behaves_like 'updates counts'
      end

      context 'with an explicit update' do
        let(:favourites) { 150 }
        let(:reblogs) { 200 }
        let(:updated) { Time.now.utc.iso8601 }

        before do
          status.update!(uri: ActivityPub::TagManager.instance.uri_for(status))
        end

        it_behaves_like 'updates counts'

        it 'changes the contents as expected' do
          expect { subject.perform }
            .to(change { status.reload.text })

          expect(status.text).to start_with("<h2>Future of the Fediverse</h2>\n\n<p>Guest article by Jane Mastodon</p><p>The fediverse is great reading this you will find out why!</p>")
        end
      end
    end
  end
end
