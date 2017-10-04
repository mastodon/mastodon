require 'rails_helper'

RSpec.describe ActivityPub::Activity::Create do
  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.with_indifferent_access
  end

  subject { described_class.new(json, sender) }

  before do
    stub_request(:get, 'http://example.com/attachment.png').to_return(request_fixture('avatar.txt'))
    stub_request(:get, 'http://example.com/icon.png').to_return(body: attachment_fixture('emojo.png'))
    stub_request(:get, 'http://example.com/icon.json').to_return(body: <<~JSON)
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "http://example.com/icon.json",
        "type": "Image",
        "url": "http://example.com/icon.png"
      }
    JSON
  end

  describe '#perform' do
    context 'standalone' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end

      it 'missing to/cc defaults to direct privacy' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.visibility).to eq 'direct'
      end
    end

    context 'public' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          to: 'https://www.w3.org/ns/activitystreams#Public',
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.visibility).to eq 'public'
      end
    end

    context 'unlisted' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          cc: 'https://www.w3.org/ns/activitystreams#Public',
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.visibility).to eq 'unlisted'
      end
    end

    context 'private' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          to: 'http://example.com/followers',
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.visibility).to eq 'private'
      end
    end

    context 'direct' do
      let(:recipient) { Fabricate(:account) }

      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          to: ActivityPub::TagManager.instance.uri_for(recipient),
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.visibility).to eq 'direct'
      end
    end

    context 'as a reply' do
      let(:original_status) { Fabricate(:status) }

      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          inReplyTo: ActivityPub::TagManager.instance.uri_for(original_status),
        }
      end

      it 'creates status' do
        subject.perform
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
          id: 'bar',
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
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.mentions.map(&:account)).to include(recipient)
      end
    end

    context 'with mentions missing href' do
      let(:object_json) do
        {
          id: 'bar',
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
        subject.perform
        status = sender.statuses.first
        expect(status).to_not be_nil
      end
    end

    context 'with media attachments' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          attachment: [
            {
              type: 'Document',
              mime_type: 'image/png',
              url: 'http://example.com/attachment.png',
            },
          ],
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.media_attachments.map(&:remote_url)).to include('http://example.com/attachment.png')
      end
    end

    context 'with media attachments missing url' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum',
          attachment: [
            {
              type: 'Document',
              mime_type: 'image/png',
            },
          ],
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first
        expect(status).to_not be_nil
      end
    end

    context 'with hashtags' do
      let(:object_json) do
        {
          id: 'bar',
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
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.tags.map(&:name)).to include('test')
      end
    end

    context 'with hashtags missing name' do
      let(:object_json) do
        {
          id: 'bar',
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
        subject.perform
        status = sender.statuses.first
        expect(status).to_not be_nil
      end
    end

    context 'with emojis' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum :tinking:',
          tag: [
            {
              type: 'Emoji',
              icon: 'http://example.com/icon.json',
              name: 'tinking',
            },
          ],
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.emojis.map(&:shortcode)).to include('tinking')
      end

      context 'when emoji icon does not exist' do
        it 'creates emoji icon when it does not exist' do
          expect(CustomEmojiIcon.where(uri: 'http://example.com/icon.json')).not_to exist

          subject.perform
          status = sender.statuses.first

          expect(CustomEmojiIcon.where(uri: 'http://example.com/icon.json')).to exist
        end

        it 'does not create emoji icon when its domain is blocked' do
          expect(CustomEmojiIcon.where(uri: 'http://example.com/icon.json')).not_to exist
          Fabricate(:domain_block, domain: 'example.com', reject_media: true)

          subject.perform
          status = sender.statuses.first

          expect(CustomEmojiIcon.where(uri: 'http://example.com/icon.json')).not_to exist
        end
      end

      context 'when emoji icon exists' do
        it 'reuses emoji icon' do
          custom_emoji_icon = Fabricate(:custom_emoji_icon, uri: 'http://example.com/icon.json')

          subject.perform
          status = sender.statuses.first

          expect(status.emojis.map(&:custom_emoji_icon)).to include(custom_emoji_icon)
        end
      end
    end

    context 'with emojis missing name' do
      let(:object_json) do
        {
          id: 'bar',
          type: 'Note',
          content: 'Lorem ipsum :tinking:',
          tag: [
            {
              type: 'Emoji',
              icon: 'http://example.com/icon.json',
            },
          ],
        }
      end

      it 'creates status' do
        subject.perform
        status = sender.statuses.first
        expect(status).to_not be_nil
      end
    end

    context 'with emojis missing icon' do
      let(:object_json) do
        {
          id: 'bar',
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
        subject.perform
        status = sender.statuses.first
        expect(status).to_not be_nil
      end
    end
  end
end
