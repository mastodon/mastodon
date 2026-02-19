# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateStatusService do
  subject { described_class.new }

  context 'when nothing changes' do
    let!(:status) { Fabricate(:status, text: 'Foo', language: 'en') }

    before do
      allow(ActivityPub::DistributionWorker).to receive(:perform_async)
    end

    it 'does not create an edit or notify anyone' do
      subject.call(status, status.account_id, text: 'Foo')

      expect(status.reload.edits)
        .to be_empty
      expect(ActivityPub::DistributionWorker)
        .to_not have_received(:perform_async)
    end
  end

  context 'when text changes' do
    let(:status) { Fabricate(:status, text: 'Foo') }
    let(:preview_card) { Fabricate(:preview_card) }

    before do
      PreviewCardsStatus.create(status: status, preview_card: preview_card)
    end

    it 'updates text, resets card, saves edit history' do
      subject.call(status, status.account_id, text: 'Bar')

      expect(status.reload)
        .to have_attributes(
          text: 'Bar',
          preview_card: be_nil
        )
      expect(status.edits.ordered.pluck(:text)).to eq %w(Foo Bar)
    end
  end

  context 'when content warning changes' do
    let(:status) { Fabricate(:status, text: 'Foo', spoiler_text: '') }
    let(:preview_card) { Fabricate(:preview_card) }

    before do
      PreviewCardsStatus.create(status: status, preview_card: preview_card)
    end

    it 'updates content warning and saves history' do
      subject.call(status, status.account_id, text: 'Foo', spoiler_text: 'Bar')

      expect(status.reload.spoiler_text)
        .to eq 'Bar'
      expect(status.edits.ordered.pluck(:text, :spoiler_text))
        .to eq [['Foo', ''], ['Foo', 'Bar']]
    end
  end

  context 'when media attachments change' do
    let!(:status) { Fabricate(:status, text: 'Foo') }
    let!(:detached_media_attachment) { Fabricate(:media_attachment, account: status.account) }
    let!(:attached_media_attachment) { Fabricate(:media_attachment, account: status.account) }

    before do
      status.media_attachments << detached_media_attachment
    end

    it 'updates media attachments, handles attachments, saves history' do
      subject.call(status, status.account_id, text: 'Foo', media_ids: [attached_media_attachment.id.to_s])

      expect(status.ordered_media_attachments)
        .to eq [attached_media_attachment]
      expect(detached_media_attachment.reload.status_id)
        .to eq status.id
      expect(attached_media_attachment.reload.status_id)
        .to eq status.id
      expect(status.edits.ordered.pluck(:ordered_media_attachment_ids))
        .to eq [[detached_media_attachment.id], [attached_media_attachment.id]]
    end
  end

  context 'when already-attached media changes' do
    let!(:status) { Fabricate(:status, text: 'Foo') }
    let!(:media_attachment) { Fabricate(:media_attachment, account: status.account, description: 'Old description') }

    before do
      status.media_attachments << media_attachment
    end

    it 'does not detach media attachment, updates description, and saves history' do
      subject.call(status, status.account_id, text: 'Foo', media_ids: [media_attachment.id.to_s], media_attributes: [{ id: media_attachment.id, description: 'New description' }])

      expect(media_attachment.reload)
        .to have_attributes(
          status_id: status.id,
          description: 'New description'
        )
      expect(status.edits.ordered.map { |edit| edit.ordered_media_attachments.map(&:description) })
        .to eq [['Old description'], ['New description']]
    end
  end

  context 'when poll changes' do
    let(:account) { Fabricate(:account) }
    let!(:status) { Fabricate(:status, text: 'Foo', account: account, poll_attributes: { options: %w(Foo Bar), account: account, multiple: false, hide_totals: false, expires_at: 7.days.from_now }) }
    let!(:poll)   { status.poll }
    let!(:voter) { Fabricate(:account) }

    before do
      status.update(poll: poll)
      VoteService.new.call(voter, poll, [0])
    end

    it 'updates poll, resets votes, saves history, requeues notifications' do
      subject.call(status, status.account_id, text: 'Foo', poll: { options: %w(Bar Baz Foo), expires_in: 5.days.to_i })

      poll = status.poll.reload

      expect(poll)
        .to have_attributes(
          options: %w(Bar Baz Foo),
          votes_count: 0,
          cached_tallies: [0, 0, 0]
        )
      expect(poll.votes.count)
        .to eq(0)

      expect(status.edits.ordered.pluck(:poll_options))
        .to eq [%w(Foo Bar), %w(Bar Baz Foo)]

      expect(PollExpirationNotifyWorker)
        .to have_enqueued_sidekiq_job(poll.id).at(poll.expires_at + 5.minutes)
    end
  end

  context 'when mentions in text change' do
    let!(:account) { Fabricate(:account) }
    let!(:alice) { Fabricate(:account, username: 'alice') }
    let!(:bob) { Fabricate(:account, username: 'bob') }
    let!(:status) { PostStatusService.new.call(account, text: 'Hello @alice') }

    it 'changes mentions and keeps old as silent' do
      subject.call(status, status.account_id, text: 'Hello @bob')

      expect(status.active_mentions.pluck(:account_id))
        .to eq [bob.id]
      expect(status.mentions.pluck(:account_id))
        .to contain_exactly(alice.id, bob.id)

      # Going back when a mention was switched to silence should still be possible
      subject.call(status, status.account_id, text: 'Hello @alice')

      expect(status.active_mentions.pluck(:account_id))
        .to eq [alice.id]
      expect(status.mentions.pluck(:account_id))
        .to contain_exactly(alice.id, bob.id)
    end
  end

  context 'when hashtags in text change' do
    let!(:account) { Fabricate(:account) }
    let!(:status) { PostStatusService.new.call(account, text: 'Hello #foo') }

    it 'changes tags' do
      subject.call(status, status.account_id, text: 'Hello #bar')

      expect(status.tags.pluck(:name)).to eq %w(bar)
    end
  end

  it 'notifies ActivityPub about the update' do
    status = Fabricate(:status, text: 'Foo')
    allow(ActivityPub::DistributionWorker).to receive(:perform_async)
    subject.call(status, status.account_id, text: 'Bar')
    expect(ActivityPub::DistributionWorker).to have_received(:perform_async)
  end
end
