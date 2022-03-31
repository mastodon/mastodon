require 'rails_helper'

RSpec.describe ActivityPub::ProcessStatusUpdateService, type: :service do
  let!(:status) { Fabricate(:status, text: 'Hello world', account: Fabricate(:account, domain: 'example.com')) }

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

  subject { described_class.new }

  describe '#call' do
    it 'updates text' do
      subject.call(status, json)
      expect(status.reload.text).to eq 'Hello universe'
    end

    it 'updates content warning' do
      subject.call(status, json)
      expect(status.reload.spoiler_text).to eq 'Show more'
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
        subject.call(status, json)
      end

      it 'does not create any edits' do
        expect(status.reload.edits).to be_empty
      end

      it 'does not mark status as edited' do
        expect(status.reload.edited?).to be false
      end

      it 'does not update the text' do
        expect(status.reload.text).to eq 'Hello world'
      end
    end

    context 'when receiving an edit older than the latest processed' do
      before do
        status.snapshot!(at_time: status.created_at, rate_limit: false)
        status.update!(text: 'Hello newer world', edited_at: Time.now.utc)
        status.snapshot!(rate_limit: false)
      end

      it 'does not create any edits' do
        expect { subject.call(status, json) }.not_to change { status.reload.edits.pluck(&:id) }
      end

      it 'does not update the text, spoiler_text or edited_at' do
        expect { subject.call(status, json) }.not_to change { s = status.reload; [s.text, s.spoiler_text, s.edited_at] }
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
        subject.call(status, json)
      end

      it 'does not create any edits' do
        expect(status.reload.edits).to be_empty
      end

      it 'does not mark status as edited' do
        expect(status.edited?).to be false
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
        subject.call(status, json)
      end

      it 'does not create any edits' do
        expect(status.reload.edits).to be_empty
      end

      it 'does not mark status as edited' do
        expect(status.edited?).to be false
      end
    end

    context 'originally without tags' do
      before do
        subject.call(status, json)
      end

      it 'updates tags' do
        expect(status.tags.reload.map(&:name)).to eq %w(hoge)
      end
    end

    context 'originally with tags' do
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
        subject.call(status, json)
      end

      it 'updates tags' do
        expect(status.tags.reload.map(&:name)).to eq %w(foo)
      end
    end

    context 'originally without mentions' do
      before do
        subject.call(status, json)
      end

      it 'updates mentions' do
        expect(status.active_mentions.reload.map(&:account_id)).to eq [alice.id]
      end
    end

    context 'originally with mentions' do
      let(:mentions) { [alice, bob] }

      before do
        subject.call(status, json)
      end

      it 'updates mentions' do
        expect(status.active_mentions.reload.map(&:account_id)).to eq [alice.id]
      end
    end

    context 'originally without media attachments' do
      before do
        allow(RedownloadMediaWorker).to receive(:perform_async)
        subject.call(status, json)
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
          ]
        }
      end

      it 'updates media attachments' do
        media_attachment = status.reload.ordered_media_attachments.first

        expect(media_attachment).to_not be_nil
        expect(media_attachment.remote_url).to eq 'https://example.com/foo.png'
      end

      it 'queues download of media attachments' do
        expect(RedownloadMediaWorker).to have_received(:perform_async)
      end

      it 'records media change in edit' do
        expect(status.edits.reload.last.ordered_media_attachment_ids).to_not be_empty
      end
    end

    context 'originally with media attachments' do
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
          ]
        }
      end

      before do
        allow(RedownloadMediaWorker).to receive(:perform_async)
        subject.call(status, json)
      end

      it 'updates the existing media attachment in-place' do
        media_attachment = status.media_attachments.reload.first

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

    context 'originally with a poll' do
      before do
        poll = Fabricate(:poll, status: status)
        status.update(preloadable_poll: poll)
        subject.call(status, json)
      end

      it 'removes poll' do
        expect(status.reload.poll).to eq nil
      end

      it 'records media change in edit' do
        expect(status.edits.reload.last.poll_options).to be_nil
      end
    end

    context 'originally without a poll' do
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
        subject.call(status, json)
      end

      it 'creates a poll' do
        poll = status.reload.poll

        expect(poll).to_not be_nil
        expect(poll.options).to eq %w(Foo Bar Baz)
      end

      it 'records media change in edit' do
        expect(status.edits.reload.last.poll_options).to eq %w(Foo Bar Baz)
      end
    end

    it 'creates edit history' do
      subject.call(status, json)
      expect(status.edits.reload.map(&:text)).to eq ['Hello world', 'Hello universe']
    end

    it 'sets edited timestamp' do
      subject.call(status, json)
      expect(status.reload.edited_at.to_s).to eq '2021-09-08 22:39:25 UTC'
    end
  end
end
