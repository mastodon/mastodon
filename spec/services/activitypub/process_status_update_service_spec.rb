# frozen_string_literal: true

require 'rails_helper'

def poll_option_json(name, votes)
  { type: 'Note', name: name, replies: { type: 'Collection', totalItems: votes } }
end

RSpec.describe ActivityPub::ProcessStatusUpdateService do
  subject { described_class.new }

  let!(:status) { Fabricate(:status, text: 'Hello world', account: Fabricate(:account, domain: 'example.com')) }
  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Note',
      summary: 'Show more',
      content: 'Hello universe',
      updated: '2021-09-08T22:39:25Z',
      tag: [
        { type: 'Hashtag', name: 'hoge' },
        { type: 'Mention', href: ActivityPub::TagManager.instance.uri_for(alice) },
      ],
    }
  end
  let(:json) { Oj.load(Oj.dump(payload)) }

  let(:alice) { Fabricate(:account) }
  let(:bob) { Fabricate(:account) }

  let(:mentions) { [] }
  let(:tags) { [] }
  let(:media_attachments) { [] }

  before do
    mentions.each { |a| Fabricate(:mention, status: status, account: a) }
    tags.each { |t| status.tags << t }
    media_attachments.each { |m| status.media_attachments << m }
  end

  describe '#call' do
    it 'updates text and content warning' do
      subject.call(status, json, json)
      expect(status.reload)
        .to have_attributes(
          text: eq('Hello universe'),
          spoiler_text: eq('Show more')
        )
    end

    context 'when the changes are only in sanitized-out HTML' do
      let!(:status) { Fabricate(:status, text: '<p>Hello world <a href="https://joinmastodon.org" rel="nofollow">joinmastodon.org</a></p>', account: Fabricate(:account, domain: 'example.com')) }

      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          updated: '2021-09-08T22:39:25Z',
          content: '<p>Hello world <a href="https://joinmastodon.org" rel="noreferrer">joinmastodon.org</a></p>',
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'does not create any edits and does not mark status edited' do
        expect(status.reload.edits).to be_empty
        expect(status).to_not be_edited
      end
    end

    context 'when the status has not been explicitly edited' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          content: 'Updated text',
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'does not create any edits, mark status edited, or update text' do
        expect(status.reload.edits).to be_empty
        expect(status.reload).to_not be_edited
        expect(status.reload.text).to eq 'Hello world'
      end
    end

    context 'when the status has not been explicitly edited and features a poll' do
      let(:account) { Fabricate(:account, domain: 'example.com') }
      let!(:expiration) { 10.days.from_now.utc }
      let!(:status) do
        Fabricate(:status,
                  text: 'Hello world',
                  account: account,
                  poll_attributes: {
                    options: %w(Foo Bar),
                    account: account,
                    multiple: false,
                    hide_totals: false,
                    expires_at: expiration,
                  })
      end

      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://example.com/foo',
          type: 'Question',
          content: 'Hello world',
          endTime: expiration.iso8601,
          oneOf: [
            poll_option_json('Foo', 4),
            poll_option_json('Bar', 3),
          ],
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'does not create any edits, mark status edited, update text but does update tallies' do
        expect(status.reload.edits).to be_empty
        expect(status.reload).to_not be_edited
        expect(status.reload.text).to eq 'Hello world'
        expect(status.poll.reload.cached_tallies).to eq [4, 3]
      end
    end

    context 'when the status changes a poll despite being not explicitly marked as updated' do
      let(:account) { Fabricate(:account, domain: 'example.com') }
      let!(:expiration) { 10.days.from_now.utc }
      let!(:status) do
        Fabricate(:status,
                  text: 'Hello world',
                  account: account,
                  poll_attributes: {
                    options: %w(Foo Bar),
                    account: account,
                    multiple: false,
                    hide_totals: false,
                    expires_at: expiration,
                  })
      end

      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://example.com/foo',
          type: 'Question',
          content: 'Hello world',
          endTime: expiration.iso8601,
          oneOf: [
            poll_option_json('Foo', 4),
            poll_option_json('Bar', 3),
            poll_option_json('Baz', 3),
          ],
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'does not create any edits, mark status edited, update text, or update tallies' do
        expect(status.reload.edits).to be_empty
        expect(status.reload).to_not be_edited
        expect(status.reload.text).to eq 'Hello world'
        expect(status.poll.reload.cached_tallies).to eq [0, 0]
      end
    end

    context 'when receiving an edit older than the latest processed' do
      before do
        status.snapshot!(at_time: status.created_at, rate_limit: false)
        status.update!(text: 'Hello newer world', edited_at: Time.now.utc)
        status.snapshot!(rate_limit: false)
      end

      it 'does not create any edits or update relevant attributes' do
        expect { subject.call(status, json, json) }
          .to not_change { status.reload.edits.pluck(&:id) }
          .and(not_change { status.reload.attributes.slice('text', 'spoiler_text', 'edited_at').values })
      end
    end

    context 'with no changes at all' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          content: 'Hello world',
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'does not create any edits or mark status edited' do
        expect(status.reload.edits).to be_empty
        expect(status).to_not be_edited
      end
    end

    context 'with no changes and originally with no ordered_media_attachment_ids' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          content: 'Hello world',
        }
      end

      before do
        status.update(ordered_media_attachment_ids: nil)
        subject.call(status, json, json)
      end

      it 'does not create any edits or mark status edited' do
        expect(status.reload.edits).to be_empty
        expect(status).to_not be_edited
      end
    end

    context 'when originally without tags' do
      before do
        subject.call(status, json, json)
      end

      it 'updates tags' do
        expect(status.tags.reload.map(&:name)).to eq %w(hoge)
      end
    end

    context 'when originally with tags' do
      let(:tags) { [Fabricate(:tag, name: 'test'), Fabricate(:tag, name: 'foo')] }

      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          summary: 'Show more',
          content: 'Hello universe',
          updated: '2021-09-08T22:39:25Z',
          tag: [
            { type: 'Hashtag', name: 'foo' },
          ],
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'updates tags' do
        expect(status.tags.reload.map(&:name)).to eq %w(foo)
      end
    end

    context 'when originally without mentions' do
      before do
        subject.call(status, json, json)
      end

      it 'updates mentions' do
        expect(status.active_mentions.reload.map(&:account_id)).to eq [alice.id]
      end
    end

    context 'when originally with mentions' do
      let(:mentions) { [alice, bob] }

      before do
        subject.call(status, json, json)
      end

      it 'updates mentions' do
        expect(status.active_mentions.reload.map(&:account_id)).to eq [alice.id]
      end
    end

    context 'when originally without media attachments' do
      before do
        stub_request(:get, 'https://example.com/foo.png').to_return(body: attachment_fixture('emojo.png'))
        subject.call(status, json, json)
      end

      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          content: 'Hello universe',
          updated: '2021-09-08T22:39:25Z',
          attachment: [
            { type: 'Image', mediaType: 'image/png', url: 'https://example.com/foo.png' },
          ],
        }
      end

      it 'updates media attachments' do
        media_attachment = status.reload.ordered_media_attachments.first

        expect(media_attachment).to_not be_nil
        expect(media_attachment.remote_url).to eq 'https://example.com/foo.png'
      end

      it 'fetches the attachment' do
        expect(a_request(:get, 'https://example.com/foo.png')).to have_been_made
      end

      it 'records media change in edit' do
        expect(status.edits.reload.last.ordered_media_attachment_ids).to_not be_empty
      end
    end

    context 'when originally with media attachments' do
      let(:media_attachments) { [Fabricate(:media_attachment, remote_url: 'https://example.com/foo.png'), Fabricate(:media_attachment, remote_url: 'https://example.com/unused.png')] }

      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Note',
          content: 'Hello universe',
          updated: '2021-09-08T22:39:25Z',
          attachment: [
            { type: 'Image', mediaType: 'image/png', url: 'https://example.com/foo.png', name: 'A picture' },
          ],
        }
      end

      before do
        allow(RedownloadMediaWorker).to receive(:perform_async)
        subject.call(status, json, json)
      end

      it 'updates the existing media attachment in-place' do
        media_attachment = status.media_attachments.ordered.reload.first

        expect(media_attachment).to_not be_nil
        expect(media_attachment.remote_url).to eq 'https://example.com/foo.png'
        expect(media_attachment.description).to eq 'A picture'
      end

      it 'does not queue redownload for the existing media attachment' do
        expect(RedownloadMediaWorker).to_not have_received(:perform_async)
      end

      it 'updates media attachments' do
        expect(status.ordered_media_attachments.map(&:remote_url)).to eq %w(https://example.com/foo.png)
      end

      it 'records media change in edit' do
        expect(status.edits.reload.last.ordered_media_attachment_ids).to_not be_empty
      end
    end

    context 'when originally with a poll' do
      before do
        poll = Fabricate(:poll, status: status)
        status.update(preloadable_poll: poll)
        subject.call(status, json, json)
      end

      it 'removes poll and records media change in edit' do
        expect(status.reload.poll).to be_nil
        expect(status.edits.reload.last.poll_options).to be_nil
      end
    end

    context 'when originally without a poll' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Question',
          content: 'Hello universe',
          updated: '2021-09-08T22:39:25Z',
          closed: true,
          oneOf: [
            { type: 'Note', name: 'Foo' },
            { type: 'Note', name: 'Bar' },
            { type: 'Note', name: 'Baz' },
          ],
        }
      end

      before do
        subject.call(status, json, json)
      end

      it 'creates a poll and records media change in edit' do
        poll = status.reload.poll

        expect(poll).to_not be_nil
        expect(poll.options).to eq %w(Foo Bar Baz)
        expect(status.edits.reload.last.poll_options).to eq %w(Foo Bar Baz)
      end
    end

    it 'creates edit history and sets edit timestamp' do
      subject.call(status, json, json)
      expect(status.edits.reload.map(&:text))
        .to eq ['Hello world', 'Hello universe']
      expect(status.reload.edited_at.to_s)
        .to eq '2021-09-08 22:39:25 UTC'
    end
  end
end
