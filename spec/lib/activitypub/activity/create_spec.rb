# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Create do
  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.with_indifferent_access
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
        tag: {
          type: 'Mention',
          href: ActivityPub::TagManager.instance.uri_for(follower),
        },
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

    def activity_for_object(json)
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: [json[:id], 'activity'].join('/'),
        type: 'Create',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: json,
      }.with_indifferent_access
    end

    before do
      follower.follow!(sender)

      # Simulate a temporary failure preventing from fetching the parent post
      stub_request(:get, object_json[:id]).to_return(status: 500)
    end

    it 'correctly processes posts and inserts them in timelines', :aggregate_failures do
      # Process reply object json
      expect { process_object_reply }
        .to create_reply_status
        .and queue_local_notifications(1)

      # Process parent object json
      expect { process_object_parent }
        .to create_parent_status
        .and add_status_to_follower_feed(reply_status)
        .and create_notifications(2)

      # Change reply to reference processed parent
      expect(reply_status.reload.in_reply_to_id)
        .to eq parent_status.id

      # Check that the parent status is in home feed
      expect(follower_home_feed_value_for(parent_status))
        .to eq(parent_status.id.to_f)
    end

    def create_notifications(count)
      change(Notification, :count)
        .from(0)
        .to(count)
    end

    def queue_local_notifications(count)
      change(LocalNotificationWorker.jobs, :size)
        .from(0)
        .to(count)
    end

    def create_reply_status
      change { reply_status }
        .from(nil)
        .to(
          have_attributes(
            reply?: be(true),
            in_reply_to_id: be_nil
          )
        )
    end

    def create_parent_status
      change { parent_status }
        .from(nil)
        .to(
          have_attributes(
            reply?: be(false),
            in_reply_to_id: be_nil
          )
        )
    end

    def process_object_reply
      # Receive the reply…
      receive_and_process(reply_json)

      # Refering explicitly to the workers is a bit awkward
      DistributionWorker.drain
      FeedInsertWorker.drain
    end

    def process_object_parent
      # Receive the parent…
      receive_and_process(object_json)

      # Drain workers
      Sidekiq::Worker.drain_all
    end

    def add_status_to_follower_feed(status)
      change { follower_home_feed_value_for(status) }
        .from(nil)
        .to(status.id.to_f)
    end

    def receive_and_process(json)
      described_class
        .new(activity_for_object(json), sender, delivery: true)
        .perform
    end

    def reply_status
      Status.find_by(uri: reply_json[:id])
    end

    def parent_status
      Status.find_by(uri: object_json[:id])
    end

    def follower_home_feed_value_for(status)
      redis.zscore(FeedManager.instance.key(:home, follower.id), status.id)
    end
  end

  describe '#perform' do
    context 'when fetching' do
      subject { described_class.new(json, sender) }

      before do
        subject.perform
      end

      context 'when object publication date is below ISO8601 range' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            published: '-0977-11-03T08:31:22Z',
          }
        end

        it 'creates status with a valid creation date', :aggregate_failures do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'

          expect(status.created_at).to be_within(30).of(Time.now.utc)
        end
      end

      context 'when object publication date is above ISO8601 range' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            published: '10000-11-03T08:31:22Z',
          }
        end

        it 'creates status with a valid creation date', :aggregate_failures do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'

          expect(status.created_at).to be_within(30).of(Time.now.utc)
        end
      end

      context 'when object has been edited' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            published: '2022-01-22T15:00:00Z',
            updated: '2022-01-22T16:00:00Z',
          }
        end

        it 'creates status with appropriate creation and edition dates', :aggregate_failures do
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
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            published: '2022-01-22T15:00:00Z',
            updated: '2022-01-22T15:00:00Z',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'
        end

        it 'does not mark status as edited' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.edited?).to be false
        end
      end

      context 'with an unknown object type' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Banana',
            content: 'Lorem ipsum',
          }
        end

        it 'does not create a status' do
          expect(sender.statuses.count).to be_zero
        end
      end

      context 'with a standalone' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.text).to eq 'Lorem ipsum'
        end

        it 'missing to/cc defaults to direct privacy' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'direct'
        end
      end

      context 'when public with explicit public address' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: 'https://www.w3.org/ns/activitystreams#Public',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'public'
        end
      end

      context 'when public with as:Public' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: 'as:Public',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'public'
        end
      end

      context 'when public with Public' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: 'Public',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'public'
        end
      end

      context 'when unlisted with explicit public address' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            cc: 'https://www.w3.org/ns/activitystreams#Public',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'unlisted'
        end
      end

      context 'when unlisted with as:Public' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            cc: 'as:Public',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'unlisted'
        end
      end

      context 'when unlisted with Public' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            cc: 'Public',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'unlisted'
        end
      end

      context 'when private' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: 'http://example.com/followers',
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'private'
        end
      end

      context 'when private with inlined Collection in audience' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: {
              type: 'OrderedCollection',
              id: 'http://example.com/followers',
              first: 'http://example.com/followers?page=true',
            },
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'private'
        end
      end

      context 'when limited' do
        let(:recipient) { Fabricate(:account) }

        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: ActivityPub::TagManager.instance.uri_for(recipient),
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'limited'
        end

        it 'creates silent mention' do
          status = sender.statuses.first
          expect(status.mentions.first).to be_silent
        end
      end

      context 'when direct' do
        let(:recipient) { Fabricate(:account) }

        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: ActivityPub::TagManager.instance.uri_for(recipient),
            tag: {
              type: 'Mention',
              href: ActivityPub::TagManager.instance.uri_for(recipient),
            },
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'direct'
        end
      end

      context 'with a reply' do
        let(:original_status) { Fabricate(:status) }

        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            inReplyTo: ActivityPub::TagManager.instance.uri_for(original_status),
          }
        end

        it 'creates status' do
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
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            tag: [
              {
                type: 'Mention',
                href: ActivityPub::TagManager.instance.uri_for(recipient),
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.mentions.map(&:account)).to include(recipient)
        end
      end

      context 'with mentions missing href' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            tag: [
              {
                type: 'Mention',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with media attachments' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
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
            ],
          }
        end

        it 'creates status with correctly-ordered media attachments' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.ordered_media_attachments.map(&:remote_url)).to eq ['http://example.com/attachment.png', 'http://example.com/emoji.png']
          expect(status.ordered_media_attachment_ids).to be_present
        end
      end

      context 'with media attachments with long description' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
                name: '*' * 1500,
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:description)).to include('*' * 1500)
        end
      end

      context 'with media attachments with long description as summary' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
                summary: '*' * 1500,
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:description)).to include('*' * 1500)
        end
      end

      context 'with media attachments with focal points' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
                url: 'http://example.com/attachment.png',
                focalPoint: [0.5, -0.7],
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:focus)).to include('0.5,-0.7')
        end
      end

      context 'with media attachments missing url' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            attachment: [
              {
                type: 'Document',
                mediaType: 'image/png',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with hashtags' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
                name: '#test',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.tags.map(&:name)).to include('test')
        end
      end

      context 'with hashtags missing name' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with hashtags invalid name' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            tag: [
              {
                type: 'Hashtag',
                href: 'http://example.com/blah',
                name: 'foo, #eh !',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with emojis' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum :tinking:',
            tag: [
              {
                type: 'Emoji',
                icon: {
                  url: 'http://example.com/emoji.png',
                },
                name: 'tinking',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.emojis.map(&:shortcode)).to include('tinking')
        end
      end

      context 'with emojis served with invalid content-type' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum :tinkong:',
            tag: [
              {
                type: 'Emoji',
                icon: {
                  url: 'http://example.com/emojib.png',
                },
                name: 'tinkong',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.emojis.map(&:shortcode)).to include('tinkong')
        end
      end

      context 'with emojis missing name' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum :tinking:',
            tag: [
              {
                type: 'Emoji',
                icon: {
                  url: 'http://example.com/emoji.png',
                },
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with emojis missing icon' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum :tinking:',
            tag: [
              {
                type: 'Emoji',
                name: 'tinking',
              },
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
        end
      end

      context 'with poll' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
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
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first
          expect(status).to_not be_nil
          expect(status.poll).to_not be_nil
        end

        it 'creates a poll' do
          poll = sender.polls.first
          expect(poll).to_not be_nil
          expect(poll.status).to_not be_nil
          expect(poll.options).to eq %w(Yellow Blue)
          expect(poll.cached_tallies).to eq [10, 3]
        end
      end

      context 'when a vote to a local poll' do
        let(:poll) { Fabricate(:poll, options: %w(Yellow Blue)) }
        let!(:local_status) { Fabricate(:status, poll: poll) }

        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            name: 'Yellow',
            inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status),
          }
        end

        it 'adds a vote to the poll with correct uri' do
          vote = poll.votes.first
          expect(vote).to_not be_nil
          expect(vote.uri).to eq object_json[:id]
          expect(poll.reload.cached_tallies).to eq [1, 0]
        end
      end

      context 'when a vote to an expired local poll' do
        let(:poll) do
          poll = Fabricate.build(:poll, options: %w(Yellow Blue), expires_at: 1.day.ago)
          poll.save(validate: false)
          poll
        end
        let!(:local_status) { Fabricate(:status, poll: poll) }

        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            name: 'Yellow',
            inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status),
          }
        end

        it 'does not add a vote to the poll' do
          expect(poll.votes.first).to be_nil
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
        }.with_indifferent_access
      end

      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          to: 'https://www.w3.org/ns/activitystreams#Public',
        }
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

    context 'with an encrypted message' do
      subject { described_class.new(json, sender, delivery: true, delivered_to_account_id: recipient.id) }

      let(:recipient) { Fabricate(:account) }
      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'EncryptedMessage',
          attributedTo: {
            type: 'Device',
            deviceId: '1234',
          },
          to: {
            type: 'Device',
            deviceId: target_device.device_id,
          },
          messageType: 1,
          cipherText: 'Foo',
          messageFranking: 'Baz678',
          digest: {
            digestAlgorithm: 'Bar456',
            digestValue: 'Foo123',
          },
        }
      end
      let(:target_device) { Fabricate(:device, account: recipient) }

      before do
        subject.perform
      end

      it 'creates an encrypted message' do
        encrypted_message = target_device.encrypted_messages.reload.first

        expect(encrypted_message)
          .to be_present
          .and have_attributes(
            from_device_id: eq('1234'),
            from_account: eq(sender),
            type: eq(1),
            body: eq('Foo'),
            digest: eq('Foo123')
          )
      end

      it 'creates a message franking' do
        encrypted_message = target_device.encrypted_messages.reload.first
        message_franking  = encrypted_message.message_franking

        crypt = ActiveSupport::MessageEncryptor.new(SystemKey.current_key, serializer: Oj)
        json  = crypt.decrypt_and_verify(message_franking)

        expect(json['source_account_id']).to eq sender.id
        expect(json['target_account_id']).to eq recipient.id
        expect(json['original_franking']).to eq 'Baz678'
      end
    end

    context 'when sender is followed by local users' do
      subject { described_class.new(json, sender, delivery: true) }

      before do
        Fabricate(:account).follow!(sender)
        subject.perform
      end

      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
        }
      end

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
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status),
        }
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
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          to: ActivityPub::TagManager.instance.uri_for(local_account),
        }
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
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          cc: ActivityPub::TagManager.instance.uri_for(local_account),
        }
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

      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
        }
      end

      it 'does not create anything' do
        expect(sender.statuses.count).to eq 0
      end
    end
  end
end
