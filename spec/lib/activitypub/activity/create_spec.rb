require 'rails_helper'

RSpec.describe ActivityPub::Activity::Create do
  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }
  let(:collection_synchronization) { nil }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
      collectionSynchronization: collection_synchronization,
    }.with_indifferent_access
  end

  before do
    sender.update(uri: ActivityPub::TagManager.instance.uri_for(sender))

    stub_request(:get, 'http://example.com/attachment.png').to_return(request_fixture('avatar.txt'))
    stub_request(:get, 'http://example.com/emoji.png').to_return(body: attachment_fixture('emojo.png'))
    stub_request(:get, 'http://example.com/emojib.png').to_return(body: attachment_fixture('emojo.png'), headers: { 'Content-Type' => 'application/octet-stream' })
  end

  describe '#perform' do
    context 'when fetching' do
      subject { described_class.new(json, sender) }

      before do
        allow(ActivityPub::FollowersSynchronizationWorker).to receive(:perform_async).and_return(nil)
        allow_any_instance_of(Account).to receive(:followers_hash).with('local').and_return('somehash')

        subject.perform
      end

      context 'with followers synchronization' do
        let(:synchronization_domain)             { Rails.configuration.x.local_domain }
        let(:synchronization_collection)         { sender.followers_url }
        let(:synchronization_partial_collection) { 'https://example.com/followers-for-domain' }
        let(:synchronization_hash_algorithm)     { 'http://www.w3.org/2001/04/xmlenc#sha256' }
        let(:synchronization_hash)               { 'somehash' }

        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
          }
        end

        let(:collection_synchronization) do
          [
            {
              type: 'SynchronizationItem',
              domain: synchronization_domain,
              object: synchronization_collection,
              partialCollection: synchronization_partial_collection,
              digest: {
                type: 'Digest',
                digestAlgorithm: synchronization_hash_algorithm,
                digestValue: synchronization_hash,
              }
            },
          ]
        end

        context 'with mismatching domain attribute' do
          let(:synchronization_domain) { 'foo.org' }

          it 'does not start a synchronization job' do
            expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
          end
        end

        context 'with mismatching object attribute' do
          let(:synchronization_collection) { 'https://example.com/followers2' }

          it 'does not start a synchronization job' do
            expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
          end
        end

        context 'with mismatching domain in partial collection attribute' do
          let(:synchronization_partial_collection) { 'https://example.org/followers' }

          it 'does not start a synchronization job' do
            expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
          end
        end

        context 'with matching digest' do
          it 'does not start a synchronization job' do
            expect(ActivityPub::FollowersSynchronizationWorker).not_to have_received(:perform_async)
          end
        end

        context 'with mismatching digest and unknown digest algorithm' do
          let(:synchronization_hash) { 'wronghash' }
          let(:synchronization_hash_algorithm) { 'foo' }

          it 'does not start a synchronization job' do
            expect(ActivityPub::FollowersSynchronizationWorker).to_not have_received(:perform_async)
          end
        end

        context 'with mismatching digest but correct algorithm' do
          let(:synchronization_hash) { 'wronghash' }

          it 'starts a synchronization job' do
            expect(ActivityPub::FollowersSynchronizationWorker).to have_received(:perform_async)
          end
        end
      end

      context 'unknown object type' do
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

      context 'standalone' do
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

      context 'public' do
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

      context 'unlisted' do
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

      context 'private' do
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

      context 'private with inlined Collection in audience' do
        let(:object_json) do
          {
            id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
            type: 'Note',
            content: 'Lorem ipsum',
            to: {
              'type': 'OrderedCollection',
              'id': 'http://example.com/followers',
              'first': 'http://example.com/followers?page=true',
            }
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.visibility).to eq 'private'
        end
      end

      context 'limited' do
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

      context 'direct' do
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

      context 'as a reply' do
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
            ],
          }
        end

        it 'creates status' do
          status = sender.statuses.first

          expect(status).to_not be_nil
          expect(status.media_attachments.map(&:remote_url)).to include('http://example.com/attachment.png')
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
                }
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
            inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status)
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
            inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status)
          }
        end

        it 'does not add a vote to the poll' do
          expect(poll.votes.first).to be_nil
        end
      end
    end

    context 'with an encrypted message' do
      let(:recipient) { Fabricate(:account) }
      let(:target_device) { Fabricate(:device, account: recipient) }

      subject { described_class.new(json, sender, delivery: true, delivered_to_account_id: recipient.id) }

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

      before do
        subject.perform
      end

      it 'creates an encrypted message' do
        encrypted_message = target_device.encrypted_messages.reload.first

        expect(encrypted_message).to_not be_nil
        expect(encrypted_message.from_device_id).to eq '1234'
        expect(encrypted_message.from_account).to eq sender
        expect(encrypted_message.type).to eq 1
        expect(encrypted_message.body).to eq 'Foo'
        expect(encrypted_message.digest).to eq 'Foo123'
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
      let!(:local_status) { Fabricate(:status) }

      subject { described_class.new(json, sender, delivery: true) }

      before do
        subject.perform
      end

      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          inReplyTo: ActivityPub::TagManager.instance.uri_for(local_status),
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'when sender targets a local user' do
      let!(:local_account) { Fabricate(:account) }

      subject { described_class.new(json, sender, delivery: true) }

      before do
        subject.perform
      end

      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          to: ActivityPub::TagManager.instance.uri_for(local_account),
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'when sender cc\'s a local user' do
      let!(:local_account) { Fabricate(:account) }

      subject { described_class.new(json, sender, delivery: true) }

      before do
        subject.perform
      end

      let(:object_json) do
        {
          id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
          type: 'Note',
          content: 'Lorem ipsum',
          cc: ActivityPub::TagManager.instance.uri_for(local_account),
        }
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
