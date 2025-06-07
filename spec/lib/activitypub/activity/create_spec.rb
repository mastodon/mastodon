# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Create do
  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }

  let(:json) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        {
          quote: {
            '@id': 'https://w3id.org/fep/044f#quote',
            '@type': '@id',
          },
        },
      ],
      id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.deep_stringify_keys
  end

  before do
    sender.update(uri: ActivityPub::TagManager.instance.uri_for(sender))

    stub_request(:get, 'http://example.com/attachment.png').to_return(request_fixture('avatar.txt'))
    stub_request(:get, 'http://example.com/emoji.png').to_return(body: attachment_fixture('emojo.png'))
    stub_request(:get, 'http://example.com/emojib.png').to_return(body: attachment_fixture('emojo.png'), headers: { 'Content-Type' => 'application/octet-stream' })
  end

  describe 'processing posts received out of order' do
    let(:follower) { Fabricate(:account, username: 'bob') }

    let(:object_json) do
      {
        id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
        type: 'Note',
        to: [
          'https://www.w3.org/ns/activitystreams#Public',
          ActivityPub::TagManager.instance.uri_for(follower),
        ],
        content: '@bob lorem ipsum',
        published: 1.hour.ago.utc.iso8601,
        updated: 1.hour.ago.utc.iso8601,
        tag: [
          {
            type: 'Mention',
            href: ActivityPub::TagManager.instance.uri_for(follower),
          },
          {
            type: 'Mention',
            href: ActivityPub::TagManager.instance.uri_for(follower),
          },
        ],
      }
    end

    let(:reply_json) do
      {
        id: [ActivityPub::TagManager.instance.uri_for(sender), 'reply'].join('/'),
        type: 'Note',
        inReplyTo: object_json[:id],
        to: [
          'https://www.w3.org/ns/activitystreams#Public',
          ActivityPub::TagManager.instance.uri_for(follower),
        ],
        content: '@bob lorem ipsum',
        published: Time.now.utc.iso8601,
        updated: Time.now.utc.iso8601,
        tag: {
          type: 'Mention',
          href: ActivityPub::TagManager.instance.uri_for(follower),
        },
      }
    end

    let(:invalid_mention_json) do
      {
        id: [ActivityPub::TagManager.instance.uri_for(sender), 'post2'].join('/'),
        type: 'Note',
        to: [
          'https://www.w3.org/ns/activitystreams#Public',
          ActivityPub::TagManager.instance.uri_for(follower),
        ],
        content: '@bob lorem ipsum',
        published: 1.hour.ago.utc.iso8601,
        updated: 1.hour.ago.utc.iso8601,
        tag: {
          type: 'Mention',
          href: 'http://notexisting.dontexistingtld/actor',
        },
      }
    end

    def activity_for_object(json)
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: [json[:id], 'activity'].join('/'),
        type: 'Create',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: json,
      }.deep_stringify_keys
    end

    before do
      follower.follow!(sender)
    end

    it 'correctly processes posts and inserts them in timelines', :aggregate_failures do
      # Simulate a temporary failure preventing from fetching the parent post
      stub_request(:get, object_json[:id]).to_return(status: 500)

      # When receiving the reply…
      described_class.new(activity_for_object(reply_json), sender, delivery: true).perform

      # NOTE: Refering explicitly to the workers is a bit awkward
      DistributionWorker.drain
      FeedInsertWorker.drain

      # …it creates a status with an unknown parent
      reply = Status.find_by(uri: reply_json[:id])
      expect(reply.reply?).to be true
      expect(reply.in_reply_to_id).to be_nil

      # …and creates a notification
      expect(LocalNotificationWorker.jobs.size).to eq 1

      # …but does not insert it into timelines
      expect(redis.zscore(FeedManager.instance.key(:home, follower.id), reply.id)).to be_nil

      # When receiving the parent…
      described_class.new(activity_for_object(object_json), sender, delivery: true).perform

      Sidekiq::Worker.drain_all

      # …it creates a status and insert it into timelines
      parent = Status.find_by(uri: object_json[:id])
      expect(parent.reply?).to be false
      expect(parent.in_reply_to_id).to be_nil
      expect(reply.reload.in_reply_to_id).to eq parent.id

      # Check that the both statuses have been inserted into the home feed
      expect(redis.zscore(FeedManager.instance.key(:home, follower.id), parent.id)).to be_within(0.1).of(parent.id.to_f)
      expect(redis.zscore(FeedManager.instance.key(:home, follower.id), reply.id)).to be_within(0.1).of(reply.id.to_f)

      # Creates two notifications
      expect(Notification.count).to eq 2
    end

    it 'ignores unprocessable mention', :aggregate_failures do
      stub_request(:get, invalid_mention_json[:tag][:href]).to_raise(HTTP::ConnectionError)
      # When receiving the post that contains an invalid mention…
      described_class.new(activity_for_object(invalid_mention_json), sender, delivery: true).perform

      # NOTE: Refering explicitly to the workers is a bit awkward
      DistributionWorker.drain
      FeedInsertWorker.drain

      # …it creates a status
      status = Status.find_by(uri: invalid_mention_json[:id])

      # Check the process did not crash
      expect(status.nil?).to be false

      # It has queued a mention resolve job
      expect(MentionResolveWorker).to have_enqueued_sidekiq_job(status.id, invalid_mention_json[:tag][:href], anything)
    end
  end

  describe '#perform' do
    context 'when fetching' do
      subject { described_class.new(json, sender) }

      context 'when object publication date is below ISO8601 range' do
        let(:object_json) do
          build_object(
            published: '-0977-11-03T08:31:22Z'
          )
        end

        it 'creates status with a valid creation date', :aggregate_failures do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'

          expect(status.created_at).to be_within(30).of(Time.now.utc)
        end
      end

      context 'when object publication date is above ISO8601 range' do
        let(:object_json) do
          build_object(
            published: '10000-11-03T08:31:22Z'
          )
        end

        it 'creates status with a valid creation date', :aggregate_failures do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'

          expect(status.created_at).to be_within(30).of(Time.now.utc)
        end
      end

      context 'when object has been edited' do
        let(:object_json) do
          build_object(
            published: '2022-01-22T15:00:00Z',
            updated: '2022-01-22T16:00:00Z'
          )
        end

        it 'creates status with appropriate creation and edition dates', :aggregate_failures do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'

          expect(status.created_at).to eq '2022-01-22T15:00:00Z'.to_datetime

          expect(status.edited?).to be true
          expect(status.edited_at).to eq '2022-01-22T16:00:00Z'.to_datetime
        end
      end

      context 'when object has update date equal to creation date' do
        let(:object_json) do
          build_object(
            published: '2022-01-22T15:00:00Z',
            updated: '2022-01-22T15:00:00Z'
          )
        end

        it 'creates status and does not mark it as edited' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'
          expect(status.edited?).to be false
        end
      end

      context 'with an unknown object type' do
        let(:object_json) do
          build_object(
            type: 'Banana'
          )
        end

        it 'does not create a status' do
          expect { subject.perform }.to_not change(sender.statuses, :count)
        end
      end

      context 'with a standalone' do
        let(:object_json) { build_object }

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'
        end

        it 'missing to/cc defaults to direct privacy' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'direct'
        end
      end

      context 'when public with explicit public address' do
        let(:object_json) do
          build_object(
            to: 'https://www.w3.org/ns/activitystreams#Public'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'public'
        end
      end

      context 'when public with as:Public' do
        let(:object_json) do
          build_object(
            to: 'as:Public'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'public'
        end
      end

      context 'when public with Public' do
        let(:object_json) do
          build_object(
            to: 'Public'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'public'
        end
      end

      context 'when unlisted with explicit public address' do
        let(:object_json) do
          build_object(
            cc: 'https://www.w3.org/ns/activitystreams#Public'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'unlisted'
        end
      end

      context 'when unlisted with as:Public' do
        let(:object_json) do
          build_object(
            cc: 'as:Public'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'unlisted'
        end
      end

      context 'when unlisted with Public' do
        let(:object_json) do
          build_object(
            cc: 'Public'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'unlisted'
        end
      end

      context 'when private' do
        let(:object_json) do
          build_object(
            to: 'http://example.com/followers'
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'private'
        end
      end

      context 'when private with inlined Collection in audience' do
        let(:object_json) do
          build_object(
            to: {
              type: 'OrderedCollection',
              id: 'http://example.com/followers',
              first: 'http://example.com/followers?page=true',
            }
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'private'
        end
      end

      context 'when limited' do
        let(:recipient) { Fabricate(:account) }

        let(:object_json) do
          build_object(
            to: ActivityPub::TagManager.instance.uri_for(recipient)
          )
        end

        it 'creates status with a silent mention' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'limited'
          expect(status.mentions.first).to be_silent
        end
      end

      context 'when direct' do
        let(:recipient) { Fabricate(:account) }

        let(:object_json) do
          build_object(
            to: ActivityPub::TagManager.instance.uri_for(recipient),
            tag: {
              type: 'Mention',
              href: ActivityPub::TagManager.instance.uri_for(recipient),
            }
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'direct'
        end
      end

      context 'with a reply' do
        let(:original_status) { Fabricate(:status) }

        let(:object_json) do
          build_object(
            inReplyTo: ActivityPub::TagManager.instance.uri_for(original_status)
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.thread).to eq original_status
          expect(status.reply?).to be true
          expect(status.in_reply_to_account).to eq original_status.account
          expect(status.conversation).to eq original_status.conversation
        end
      end

      context 'with mentions' do
        let(:recipient) { Fabricate(:account) }

        let(:object_json) do
          build_object(
            tag: [
              {
                type: 'Mention',
                href: ActivityPub::TagManager.instance.uri_for(recipient),
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.mentions.map(&:account)).to include(recipient)
        end
      end

      context 'with mentions missing href' do
        let(:object_json) do
          build_object(
            tag: [
              {
                type: 'Mention',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with media attachments' do
        let(:object_json) do
          build_object(
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
              },
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/emoji.png',
              },
            ]
          )
        end

        it 'creates status with correctly-ordered media attachments' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.ordered_media_attachments.map(&:remote_url)).to eq ['http://example.com/attachment.png', 'http://example.com/emoji.png']
          expect(status.ordered_media_attachment_ids).to be_present
        end
      end

      context 'with media attachments with long description' do
        let(:object_json) do
          build_object(
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
                name: '*' * MediaAttachment::MAX_DESCRIPTION_LENGTH,
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:description)).to include('*' * MediaAttachment::MAX_DESCRIPTION_LENGTH)
        end
      end

      context 'with media attachments with long description as summary' do
        let(:object_json) do
          build_object(
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
                summary: '*' * MediaAttachment::MAX_DESCRIPTION_LENGTH,
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:description)).to include('*' * MediaAttachment::MAX_DESCRIPTION_LENGTH)
        end
      end

      context 'with media attachments with focal points' do
        let(:object_json) do
          build_object(
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
                focalPoint: [0.5, -0.7],
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:focus)).to include('0.5,-0.7')
        end
      end

      context 'with media attachments missing url' do
        let(:object_json) do
          build_object(
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with hashtags' do
        let(:object_json) do
          build_object(
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
                name: '#test',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.tags.map(&:name)).to include('test')
        end
      end

      context 'with featured hashtags' do
        let(:object_json) do
          build_object(
            to: 'https://www.w3.org/ns/activitystreams#Public',
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
                name: '#test',
              },
            ]
          )
        end

        before do
          sender.featured_tags.create!(name: 'test')
        end

        it 'creates status and updates featured tag' do
          expect { subject.perform }
            .to change(sender.statuses, :count).by(1)
            .and change { sender.featured_tags.first.reload.statuses_count }.by(1)
            .and change { sender.featured_tags.first.reload.last_status_at }.from(nil).to(be_present)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.tags.map(&:name)).to include('test')
        end
      end

      context 'with hashtags missing name' do
        let(:object_json) do
          build_object(
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with hashtags invalid name' do
        let(:object_json) do
          build_object(
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
                name: 'foo, #eh !',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with emojis' do
        let(:object_json) do
          build_object(
            content: 'Lorem ipsum :tinking:',
            tag: [
              {
                type: 'Emoji',
                icon: {
                  url: 'http://example.com/emoji.png',
                },
                name: 'tinking',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.emojis.map(&:shortcode)).to include('tinking')
        end
      end

      context 'with emojis served with invalid content-type' do
        let(:object_json) do
          build_object(
            content: 'Lorem ipsum :tinkong:',
            tag: [
              {
                type: 'Emoji',
                icon: {
                  url: 'http://example.com/emojib.png',
                },
                name: 'tinkong',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.emojis.map(&:shortcode)).to include('tinkong')
        end
      end

      context 'with emojis missing name' do
        let(:object_json) do
          build_object(
            content: 'Lorem ipsum :tinking:',
            tag: [
              {
                type: 'Emoji',
                icon: {
                  url: 'http://example.com/emoji.png',
                },
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with emojis missing icon' do
        let(:object_json) do
          build_object(
            content: 'Lorem ipsum :tinking:',
            tag: [
              {
                type: 'Emoji',
                name: 'tinking',
              },
            ]
          )
        end

        it 'creates status' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with poll' do
        let(:object_json) do
          build_object(
            type: 'Question',
            content: 'Which color was the submarine?',
            oneOf: [
              {
                name: 'Yellow',
                replies: {
                  type: 'Collection',
                  totalItems: 10,
                },
              },
              {
                name: 'Blue',
                replies: {
                  type: 'Collection',
                  totalItems: 3,
                },
              },
            ]
          )
        end

        it 'creates status with a poll' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
          expect(status.poll).to_not be_nil

          poll = sender.polls.first
          expect(poll).to_not be_nil
          expect(poll.status).to_not be_nil
          expect(poll.options).to eq %w(Yellow Blue)
          expect(poll.cached_tallies).to eq [10, 3]
        end
      end

      context 'with an unverifiable quote of a known post' do
        let(:quoted_status) { Fabricate(:status) }

        let(:object_json) do
          build_object(
            type: 'Note',
            content: 'woah what she said is amazing',
            quote: ActivityPub::TagManager.instance.uri_for(quoted_status)
          )
        end

        it 'creates a status with an unverified quote' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
          expect(status.quote).to_not be_nil
          expect(status.quote).to have_attributes(
            state: 'pending',
            approval_uri: nil
          )
        end
      end

      context 'with an unverifiable unknown post' do
        let(:unknown_post_uri) { 'https://unavailable.example.com/unavailable-post' }

        let(:object_json) do
          build_object(
            type: 'Note',
            content: 'woah what she said is amazing',
            quote: unknown_post_uri
          )
        end

        before do
          stub_request(:get, unknown_post_uri).to_return(status: 404)
        end

        it 'creates a status with an unverified quote' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
          expect(status.quote).to_not be_nil
          expect(status.quote).to have_attributes(
            state: 'pending',
            approval_uri: nil
          )
        end
      end

      context 'with a verifiable quote of a known post' do
        let(:quoted_account) { Fabricate(:account, domain: 'quoted.example.com') }
        let(:quoted_status) { Fabricate(:status, account: quoted_account) }
        let(:approval_uri) { 'https://quoted.example.com/quote-approval' }

        let(:object_json) do
          build_object(
            type: 'Note',
            content: 'woah what she said is amazing',
            quote: ActivityPub::TagManager.instance.uri_for(quoted_status),
            quoteAuthorization: approval_uri
          )
        end

        before do
          stub_request(:get, approval_uri).to_return(headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump({
            '@context': [
              'https://www.w3.org/ns/activitystreams',
              {
                QuoteAuthorization: 'https://w3id.org/fep/044f#QuoteAuthorization',
                gts: 'https://gotosocial.org/ns#',
                interactionPolicy: {
                  '@id': 'gts:interactionPolicy',
                  '@type': '@id',
                },
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
            interactingObject: object_json[:id],
            interactionTarget: ActivityPub::TagManager.instance.uri_for(quoted_status),
          }))
        end

        it 'creates a status with a verified quote' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status).to_not be_nil
          expect(status.quote).to_not be_nil
          expect(status.quote).to have_attributes(
            state: 'accepted',
            approval_uri: approval_uri
          )
        end
      end

      context 'when a vote to a local poll' do
        let(:poll) { Fabricate(:poll, options: %w(Yellow Blue)) }
        let!(:local_status) { Fabricate(:status, poll: poll) }

        let(:object_json) do
          build_object(
            name: 'Yellow',
            inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status)
          ).except(:content)
        end

        it 'adds a vote to the poll with correct uri' do
          expect { subject.perform }.to change(poll.votes, :count).by(1)

          vote = poll.votes.first
          expect(vote).to_not be_nil
          expect(vote.uri).to eq object_json[:id]
          expect(poll.reload.cached_tallies).to eq [1, 0]
        end
      end

      context 'when a vote to an expired local poll' do
        let(:poll) do
          travel_to 2.days.ago do
            Fabricate(:poll, options: %w(Yellow Blue), expires_at: 1.day.from_now)
          end
        end
        let!(:local_status) { Fabricate(:status, poll: poll) }

        let(:object_json) do
          build_object(
            name: 'Yellow',
            inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status)
          ).except(:content)
        end

        it 'does not add a vote to the poll' do
          expect { subject.perform }.to_not change(poll.votes, :count)

          expect(poll.votes.first).to be_nil
        end
      end

      context 'with counts' do
        let(:object_json) do
          build_object(
            likes: {
              id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar', '/likes'].join,
              type: 'Collection',
              totalItems: 50,
            },
            shares: {
              id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar', '/shares'].join,
              type: 'Collection',
              totalItems: 100,
            }
          )
        end

        it 'uses the counts from the created object' do
          expect { subject.perform }.to change(sender.statuses, :count).by(1)

          status = sender.statuses.first
          expect(status.untrusted_favourites_count).to eq 50
          expect(status.untrusted_reblogs_count).to eq 100
        end
      end
    end

    context 'when object URI uses bearcaps' do
      subject { described_class.new(json, sender) }

      let(:token) { 'foo' }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
          type: 'Create',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: Addressable::URI.new(scheme: 'bear', query_values: { t: token, u: object_json[:id] }).to_s,
        }.deep_stringify_keys
      end

      let(:object_json) do
        build_object(
          to: 'https://www.w3.org/ns/activitystreams#Public'
        )
      end

      before do
        stub_request(:get, object_json[:id])
          .with(headers: { Authorization: "Bearer #{token}" })
          .to_return(body: Oj.dump(object_json), headers: { 'Content-Type': 'application/activity+json' })

        subject.perform
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status).to have_attributes(
          visibility: 'public',
          text: 'Lorem ipsum'
        )
      end
    end

    context 'when sender is followed by local users' do
      subject { described_class.new(json, sender, delivery: true) }

      before do
        Fabricate(:account).follow!(sender)
        subject.perform
      end

      let(:object_json) { build_object }

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'when sender replies to local status' do
      subject { described_class.new(json, sender, delivery: true) }

      let!(:local_status) { Fabricate(:status) }
      let(:object_json) do
        build_object(
          inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status)
        )
      end

      before do
        subject.perform
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'when sender targets a local user' do
      subject { described_class.new(json, sender, delivery: true) }

      let!(:local_account) { Fabricate(:account) }

      let(:object_json) do
        build_object(
          to: ActivityPub::TagManager.instance.uri_for(local_account)
        )
      end

      before do
        subject.perform
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'when sender cc\'s a local user' do
      subject { described_class.new(json, sender, delivery: true) }

      let!(:local_account) { Fabricate(:account) }
      let(:object_json) do
        build_object(
          cc: ActivityPub::TagManager.instance.uri_for(local_account)
        )
      end

      before do
        subject.perform
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'when the sender has no relevance to local activity' do
      subject { described_class.new(json, sender, delivery: true) }

      before do
        subject.perform
      end

      let(:object_json) { build_object }

      it 'does not create anything' do
        expect(sender.statuses.count).to eq 0
      end
    end

    def build_object(options = {})
      {
        id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
        type: 'Note',
        content: 'Lorem ipsum',
      }.merge(options)
    end
  end
end
