# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateStatusService, type: :service do
  subject { described_class.new }

  context 'when nothing changes' do
    let!(:status) { Fabricate(:status, text: 'Foo', language: 'en') }

    before do
      allow(ActivityPub::DistributionWorker).to receive(:perform_async)
      subject.call(status, status.account_id, text: 'Foo')
    end

    it 'does not create an edit' do
      expect(status.reload.edits).to be_empty
    end

    it 'does not notify anyone' do
      expect(ActivityPub::DistributionWorker).to_not have_received(:perform_async)
    end
  end

  context 'when text changes' do
    let!(:status) { Fabricate(:status, text: 'Foo') }
    let(:preview_card) { Fabricate(:preview_card) }

    before do
      status.preview_cards << preview_card
      subject.call(status, status.account_id, text: 'Bar')
    end

    it 'updates text' do
      expect(status.reload.text).to eq 'Bar'
    end

    it 'resets preview card' do
      expect(status.reload.preview_card).to be_nil
    end

    it 'saves edit history' do
      expect(status.edits.pluck(:text)).to eq %w(Foo Bar)
    end
  end

  context 'when content warning changes' do
    let!(:status) { Fabricate(:status, text: 'Foo', spoiler_text: '') }
    let(:preview_card) { Fabricate(:preview_card) }

    before do
      status.preview_cards << preview_card
      subject.call(status, status.account_id, text: 'Foo', spoiler_text: 'Bar')
    end

    it 'updates content warning' do
      expect(status.reload.spoiler_text).to eq 'Bar'
    end

    it 'saves edit history' do
      expect(status.edits.pluck(:text, :spoiler_text)).to eq [['Foo', ''], ['Foo', 'Bar']]
    end
  end

  context 'when media attachments change' do
    let!(:status) { Fabricate(:status, text: 'Foo') }
    let!(:detached_media_attachment) { Fabricate(:media_attachment, account: status.account) }
    let!(:attached_media_attachment) { Fabricate(:media_attachment, account: status.account) }

    before do
      status.media_attachments << detached_media_attachment
      subject.call(status, status.account_id, text: 'Foo', media_ids: [attached_media_attachment.id])
    end

    it 'updates media attachments' do
      expect(status.ordered_media_attachments).to eq [attached_media_attachment]
    end

    it 'does not detach detached media attachments' do
      expect(detached_media_attachment.reload.status_id).to eq status.id
    end

    it 'attaches attached media attachments' do
      expect(attached_media_attachment.reload.status_id).to eq status.id
    end

    it 'saves edit history' do
      expect(status.edits.pluck(:ordered_media_attachment_ids)).to eq [[detached_media_attachment.id], [attached_media_attachment.id]]
    end
  end

  context 'when already-attached media changes' do
    let!(:status) { Fabricate(:status, text: 'Foo') }
    let!(:media_attachment) { Fabricate(:media_attachment, account: status.account, description: 'Old description') }

    before do
      status.media_attachments << media_attachment
      subject.call(status, status.account_id, text: 'Foo', media_ids: [media_attachment.id], media_attributes: [{ id: media_attachment.id, description: 'New description' }])
    end

    it 'does not detach media attachment' do
      expect(media_attachment.reload.status_id).to eq status.id
    end

    it 'updates the media attachment description' do
      expect(media_attachment.reload.description).to eq 'New description'
    end

    it 'saves edit history' do
      expect(status.edits.map { |edit| edit.ordered_media_attachments.map(&:description) }).to eq [['Old description'], ['New description']]
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
      subject.call(status, status.account_id, text: 'Foo', poll: { options: %w(Bar Baz Foo), expires_in: 5.days.to_i })
    end

    it 'updates poll' do
      poll = status.poll.reload
      expect(poll.options).to eq %w(Bar Baz Foo)
    end

    it 'resets votes' do
      poll = status.poll.reload
      expect(poll.votes_count).to eq 0
      expect(poll.votes.count).to eq 0
      expect(poll.cached_tallies).to eq [0, 0, 0]
    end

    it 'saves edit history' do
      expect(status.edits.pluck(:poll_options)).to eq [%w(Foo Bar), %w(Bar Baz Foo)]
    end
  end

  context 'when mentions in text change' do
    let!(:account) { Fabricate(:account) }
    let!(:alice) { Fabricate(:account, username: 'alice') }
    let!(:bob) { Fabricate(:account, username: 'bob') }
    let!(:status) { PostStatusService.new.call(account, text: 'Hello @alice') }

    before do
      subject.call(status, status.account_id, text: 'Hello @bob')
    end

    it 'changes mentions' do
      expect(status.active_mentions.pluck(:account_id)).to eq [bob.id]
    end

    it 'keeps old mentions as silent mentions' do
      expect(status.mentions.pluck(:account_id)).to contain_exactly(alice.id, bob.id)
    end
  end

  context 'when hashtags in text change' do
    let!(:account) { Fabricate(:account) }
    let!(:status) { PostStatusService.new.call(account, text: 'Hello #foo') }

    before do
      subject.call(status, status.account_id, text: 'Hello #bar')
    end

    it 'changes tags' do
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
