# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteStatusService do
  include ActionView::Helpers::TextHelper

  subject { described_class.new }

  let!(:sender) { Fabricate(:account, domain: 'foo.bar', uri: 'https://foo.bar') }

  let(:follower) { Fabricate(:account, username: 'alice') }
  let(:follow) { nil }
  let(:response) { { body: Oj.dump(object), headers: { 'content-type': 'application/activity+json' } } }
  let(:existing_status) { nil }

  let(:note) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://foo.bar/@foo/1234',
      type: 'Note',
      content: 'Lorem ipsum',
      attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
    }
  end

  before do
    stub_request(:get, 'https://foo.bar/watch?v=12345').to_return(status: 404, body: '')
    stub_request(:get, object[:id]).to_return(**response)
  end

  describe '#call' do
    before do
      follow
      existing_status
      subject.call(object[:id])
    end

    context 'with Note object' do
      let(:object) { note }

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'with Video object' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1234',
          type: 'Video',
          name: 'Nyan Cat 10 hours remix',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
          url: [
            {
              type: 'Link',
              mimeType: 'application/x-bittorrent',
              href: 'https://foo.bar/12345.torrent',
            },

            {
              type: 'Link',
              mimeType: 'text/html',
              href: 'https://foo.bar/watch?v=12345',
            },
          ],
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.url).to eq 'https://foo.bar/watch?v=12345'
        expect(strip_tags(status.text)).to eq "Nyan Cat 10 hours remix\n\nhttps://foo.bar/watch?v=12345"
      end
    end

    context 'with Audio object' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1234',
          type: 'Audio',
          name: 'Nyan Cat 10 hours remix',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
          url: [
            {
              type: 'Link',
              mimeType: 'application/x-bittorrent',
              href: 'https://foo.bar/12345.torrent',
            },

            {
              type: 'Link',
              mimeType: 'text/html',
              href: 'https://foo.bar/watch?v=12345',
            },
          ],
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.url).to eq 'https://foo.bar/watch?v=12345'
        expect(strip_tags(status.text)).to eq "Nyan Cat 10 hours remix\n\nhttps://foo.bar/watch?v=12345"
      end
    end

    context 'with Event object' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1234',
          type: 'Event',
          name: "Let's change the world",
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.url).to eq 'https://foo.bar/@foo/1234'
        expect(strip_tags(status.text)).to eq "Let's change the world\n\nhttps://foo.bar/@foo/1234"
      end
    end

    context 'with Event object that contains a HTML summary' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1234',
          type: 'Event',
          name: 'Fediverse Birthday Party',
          startTime: '2024-01-31T20:00:00.000+01:00',
          location: {
            type: 'Place',
            name: 'FooBar – The not converted location',
          },
          content: 'The not converted detailed description of the event object.',
          summary: '<p>See you at the <strong>FooBar</strong>!</p><ul><li><strong>Doors:</strong> 8pm</li><li><strong>Music:</strong> 10pm</li></ul>',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.url).to eq 'https://foo.bar/@foo/1234'
        expect(status.text).to start_with "<h2>#{object[:name]}</h2>\n\n#{object[:summary]}\n\n"
        expect(status.text).to include "href=\"#{object[:id]}\""
      end
    end

    context 'with Article object that contains a HTML summary' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/blog/future-of-the-fediverse',
          type: 'Article',
          name: 'Future of the Fediverse',
          content: 'Lorem Ipsum',
          summary: '<p>Guest article by <a href="https://john.mastodon">John Mastodon</a></p><p>The fediverse is great reading this you will find out why!</p>',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.url).to eq object[:id]
        expect(status.text).to start_with "<h2>#{object[:name]}</h2>\n\n#{object[:summary]}\n\n"
        expect(status.text).to include "href=\"#{object[:id]}\""
      end
    end

    context 'with wrong id' do
      let(:note) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://real.address/@foo/1234',
          type: 'Note',
          content: 'Lorem ipsum',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      let(:object) do
        temp = note.dup
        temp[:id] = 'https://fake.address/@foo/5678'
        temp
      end

      it 'does not create status' do
        expect(sender.statuses.first).to be_nil
      end
    end

    context 'with a valid Create activity' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1234/create',
          type: 'Create',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: note,
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.uri).to eq note[:id]
        expect(status.text).to eq note[:content]
      end
    end

    context 'with a Create activity with a mismatching id' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1234/create',
          type: 'Create',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: {
            id: 'https://real.address/@foo/1234',
            type: 'Note',
            content: 'Lorem ipsum',
            attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
          },
        }
      end

      it 'does not create status' do
        expect(sender.statuses.first).to be_nil
      end
    end

    context 'when status already exists' do
      let(:existing_status) { Fabricate(:status, account: sender, text: 'Foo', uri: note[:id]) }

      context 'with a Note object' do
        let(:object) { note.merge(updated: '2021-09-08T22:39:25Z') }

        it 'updates status' do
          existing_status.reload
          expect(existing_status.text).to eq 'Lorem ipsum'
          expect(existing_status.edits).to_not be_empty
        end

        context 'when the status appears to have been deleted at source' do
          let(:response) { { status: 404, body: '' } }

          shared_examples 'no delete' do
            it 'does not delete the status' do
              existing_status.reload
              expect(existing_status.text).to eq 'Foo'
              expect(existing_status.edits).to be_empty
            end
          end

          context 'when the status is orphaned/unsubscribed' do
            it 'deletes the orphaned status' do
              expect { existing_status.reload }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context 'when the status is from an account with only remote followers' do
            let(:follower) { Fabricate(:account, username: 'alice', domain: 'foo.bar') }
            let(:follow) { Fabricate(:follow, account: follower, target_account: sender, created_at: 2.days.ago) }

            it 'deletes the orphaned status' do
              expect { existing_status.reload }.to raise_error(ActiveRecord::RecordNotFound)
            end

            context 'when the status is private' do
              let(:existing_status) { Fabricate(:status, account: sender, text: 'Foo', uri: note[:id], visibility: :private) }

              it_behaves_like 'no delete'
            end

            context 'when the status is direct' do
              let(:existing_status) { Fabricate(:status, account: sender, text: 'Foo', uri: note[:id], visibility: :direct) }

              it_behaves_like 'no delete'
            end
          end
        end
      end

      context 'with a Create activity' do
        let(:object) do
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'https://foo.bar/@foo/1234/create',
            type: 'Create',
            actor: ActivityPub::TagManager.instance.uri_for(sender),
            object: note.merge(updated: '2021-09-08T22:39:25Z'),
          }
        end

        it 'updates status' do
          existing_status.reload
          expect(existing_status.text).to eq 'Lorem ipsum'
          expect(existing_status.edits).to_not be_empty
        end
      end
    end
  end

  context 'with statuses referencing other statuses', :inline_jobs do
    before do
      stub_const 'ActivityPub::FetchRemoteStatusService::DISCOVERIES_PER_REQUEST', 3
    end

    context 'when using inReplyTo' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1',
          type: 'Note',
          content: 'Lorem ipsum',
          inReplyTo: 'https://foo.bar/@foo/2',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      before do
        5.times do |i|
          status_json = {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: "https://foo.bar/@foo/#{i}",
            type: 'Note',
            content: 'Lorem ipsum',
            inReplyTo: "https://foo.bar/@foo/#{i + 1}",
            attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
            to: 'as:Public',
          }.with_indifferent_access
          stub_request(:get, "https://foo.bar/@foo/#{i}").to_return(status: 200, body: status_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        end
      end

      it 'creates statuses but not more than limit allows' do
        expect { subject.call(object[:id], prefetched_body: Oj.dump(object)) }
          .to change { sender.statuses.count }.by_at_least(2)
          .and change { sender.statuses.count }.by_at_most(3)
      end
    end

    context 'when using replies' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://foo.bar/@foo/1',
          type: 'Note',
          content: 'Lorem ipsum',
          replies: {
            type: 'Collection',
            id: 'https://foo.bar/@foo/1/replies',
            first: {
              type: 'CollectionPage',
              partOf: 'https://foo.bar/@foo/1/replies',
              items: ['https://foo.bar/@foo/2'],
            },
          },
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
        }
      end

      before do
        5.times do |i|
          status_json = {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: "https://foo.bar/@foo/#{i}",
            type: 'Note',
            content: 'Lorem ipsum',
            replies: {
              type: 'Collection',
              id: "https://foo.bar/@foo/#{i}/replies",
              first: {
                type: 'CollectionPage',
                partOf: "https://foo.bar/@foo/#{i}/replies",
                items: ["https://foo.bar/@foo/#{i + 1}"],
              },
            },
            attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
            to: 'as:Public',
          }.with_indifferent_access
          stub_request(:get, "https://foo.bar/@foo/#{i}").to_return(status: 200, body: status_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        end
      end

      it 'creates statuses but not more than limit allows' do
        expect { subject.call(object[:id], prefetched_body: Oj.dump(object)) }
          .to change { sender.statuses.count }.by_at_least(2)
          .and change { sender.statuses.count }.by_at_most(3)
      end
    end
  end
end
