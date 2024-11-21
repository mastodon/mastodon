# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkImportService do
  subject { described_class.new }

  let(:account) { Fabricate(:account) }
  let(:import) { Fabricate(:bulk_import, account: account, type: import_type, overwrite: overwrite, state: :in_progress, imported_items: 0, processed_items: 0) }

  before do
    import.update(total_items: import.rows.count)
  end

  describe '#call' do
    context 'when importing follows' do
      let(:import_type) { 'following' }
      let(:overwrite)   { false }

      let!(:rows) do
        [
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before { account.follow!(Fabricate(:account)) }

      it 'does not immediately change who the account follows, enqueues workers, sends follow requests after worker run' do
        expect { subject.call(import) }
          .to_not(change { account.reload.active_relationships.to_a })

        expect(row_worker_job_args)
          .to match_array(rows.map(&:id))

        stub_resolve_account_and_drain_workers

        expect(FollowRequest.includes(:target_account).where(account: account).map { |follow_request| follow_request.target_account.acct })
          .to contain_exactly('user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing follows with overwrite' do
      let(:import_type) { 'following' }
      let(:overwrite)   { true }

      let!(:followed)         { Fabricate(:account, username: 'followed', domain: 'foo.bar', protocol: :activitypub) }
      let!(:to_be_unfollowed) { Fabricate(:account, username: 'to_be_unfollowed', domain: 'foo.bar', protocol: :activitypub) }

      let!(:rows) do
        [
          { 'acct' => 'followed@foo.bar', 'show_reblogs' => false, 'notify' => true, 'languages' => ['en'] },
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.follow!(followed, reblogs: true, notify: false)
        account.follow!(to_be_unfollowed)
      end

      it 'updates the existing follow relationship as expected and unfollows user not on list, enqueues workers, sends follow reqs after worker run' do
        expect { subject.call(import) }
          .to change { Follow.where(account: account, target_account: followed).pick(:show_reblogs, :notify, :languages) }.from([true, false, nil]).to([false, true, ['en']])

        expect(account)
          .to_not be_following(to_be_unfollowed)

        expect(row_worker_job_args)
          .to match_array(rows[1..].map(&:id))

        stub_resolve_account_and_drain_workers

        expect(FollowRequest.includes(:target_account).where(account: account).map { |follow_request| follow_request.target_account.acct })
          .to contain_exactly('user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing blocks' do
      let(:import_type) { 'blocking' }
      let(:overwrite)   { false }

      let!(:rows) do
        [
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before { account.block!(Fabricate(:account, username: 'already_blocked', domain: 'remote.org')) }

      it 'does not immediately change who the account blocks, enqueues worker, blocks after run' do
        expect { subject.call(import) }
          .to_not(change { account.reload.blocking.to_a })

        expect(row_worker_job_args)
          .to match_array(rows.map(&:id))

        stub_resolve_account_and_drain_workers

        expect(account.reload.blocking.map(&:acct))
          .to contain_exactly('already_blocked@remote.org', 'user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing blocks with overwrite' do
      let(:import_type) { 'blocking' }
      let(:overwrite)   { true }

      let!(:blocked)         { Fabricate(:account, username: 'blocked', domain: 'foo.bar', protocol: :activitypub) }
      let!(:to_be_unblocked) { Fabricate(:account, username: 'to_be_unblocked', domain: 'foo.bar', protocol: :activitypub) }

      let!(:rows) do
        [
          { 'acct' => 'blocked@foo.bar' },
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.block!(blocked)
        account.block!(to_be_unblocked)
      end

      it 'unblocks user not present on list, enqueues worker, requests follow after run' do
        subject.call(import)

        expect(account.blocking?(to_be_unblocked)).to be false

        expect(row_worker_job_args)
          .to match_array(rows[1..].map(&:id))

        stub_resolve_account_and_drain_workers

        expect(account.blocking.map(&:acct))
          .to contain_exactly('blocked@foo.bar', 'user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing mutes' do
      let(:import_type) { 'muting' }
      let(:overwrite)   { false }

      let!(:rows) do
        [
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before { account.mute!(Fabricate(:account, username: 'already_muted', domain: 'remote.org')) }

      it 'does not immediately change who the account blocks, enqueures worker, mutes users after worker run' do
        expect { subject.call(import) }
          .to_not(change { account.reload.muting.to_a })

        expect(row_worker_job_args)
          .to match_array(rows.map(&:id))

        stub_resolve_account_and_drain_workers

        expect(account.reload.muting.map(&:acct))
          .to contain_exactly('already_muted@remote.org', 'user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing mutes with overwrite' do
      let(:import_type) { 'muting' }
      let(:overwrite)   { true }

      let!(:muted)         { Fabricate(:account, username: 'muted', domain: 'foo.bar', protocol: :activitypub) }
      let!(:to_be_unmuted) { Fabricate(:account, username: 'to_be_unmuted', domain: 'foo.bar', protocol: :activitypub) }

      let!(:rows) do
        [
          { 'acct' => 'muted@foo.bar', 'hide_notifications' => true },
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.mute!(muted, notifications: false)
        account.mute!(to_be_unmuted)
      end

      it 'updates the existing mute as expected and unblocks user not on list, and enqueues worker, and requests follow after worker run' do
        expect { subject.call(import) }
          .to change { Mute.where(account: account, target_account: muted).pick(:hide_notifications) }.from(false).to(true)

        expect(account.muting?(to_be_unmuted)).to be false

        expect(row_worker_job_args)
          .to match_array(rows[1..].map(&:id))

        stub_resolve_account_and_drain_workers

        expect(account.muting.map(&:acct))
          .to contain_exactly('muted@foo.bar', 'user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing domain blocks' do
      let(:import_type) { 'domain_blocking' }
      let(:overwrite)   { false }

      let(:rows) do
        [
          { 'domain' => 'blocked.com' },
          { 'domain' => 'to-block.com' },
        ]
      end

      before do
        rows.each { |data| import.rows.create!(data: data) }
        account.block_domain!('alreadyblocked.com')
        account.block_domain!('blocked.com')
      end

      it 'blocks all the new domains and marks import finished' do
        subject.call(import)

        expect(account.domain_blocks.pluck(:domain))
          .to contain_exactly('alreadyblocked.com', 'blocked.com', 'to-block.com')
        expect(import.reload.state_finished?).to be true
      end
    end

    context 'when importing domain blocks with overwrite' do
      let(:import_type) { 'domain_blocking' }
      let(:overwrite)   { true }

      let(:rows) do
        [
          { 'domain' => 'blocked.com' },
          { 'domain' => 'to-block.com' },
        ]
      end

      before do
        rows.each { |data| import.rows.create!(data: data) }
        account.block_domain!('alreadyblocked.com')
        account.block_domain!('blocked.com')
      end

      it 'blocks all the new domains and marks import finished' do
        subject.call(import)

        expect(account.domain_blocks.pluck(:domain))
          .to contain_exactly('blocked.com', 'to-block.com')
        expect(import.reload.state_finished?)
          .to be true
      end
    end

    context 'when importing bookmarks' do
      let(:import_type) { 'bookmarks' }
      let(:overwrite)   { false }

      let!(:already_bookmarked)  { Fabricate(:status, uri: 'https://already.bookmarked/1') }
      let!(:status)              { Fabricate(:status, uri: 'https://foo.bar/posts/1') }
      let!(:inaccessible_status) { Fabricate(:status, uri: 'https://foo.bar/posts/inaccessible', visibility: :direct) }
      let!(:bookmarked)          { Fabricate(:status, uri: 'https://foo.bar/posts/already-bookmarked') }

      let!(:rows) do
        [
          { 'uri' => status.uri },
          { 'uri' => inaccessible_status.uri },
          { 'uri' => bookmarked.uri },
          { 'uri' => 'https://domain.unknown/foo' },
          { 'uri' => 'https://domain.unknown/private' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.bookmarks.create!(status: already_bookmarked)
        account.bookmarks.create!(status: bookmarked)
      end

      it 'enqueues workers for the expected rows and updates bookmarks after worker run' do
        subject.call(import)

        expect(row_worker_job_args)
          .to match_array(rows.map(&:id))

        stub_fetch_remote_and_drain_workers

        expect(account.bookmarks.map { |bookmark| bookmark.status.uri })
          .to contain_exactly(already_bookmarked.uri, status.uri, bookmarked.uri, 'https://domain.unknown/foo')
      end
    end

    context 'when importing bookmarks with overwrite' do
      let(:import_type) { 'bookmarks' }
      let(:overwrite)   { true }

      let!(:already_bookmarked)  { Fabricate(:status, uri: 'https://already.bookmarked/1') }
      let!(:status)              { Fabricate(:status, uri: 'https://foo.bar/posts/1') }
      let!(:inaccessible_status) { Fabricate(:status, uri: 'https://foo.bar/posts/inaccessible', visibility: :direct) }
      let!(:bookmarked)          { Fabricate(:status, uri: 'https://foo.bar/posts/already-bookmarked') }

      let!(:rows) do
        [
          { 'uri' => status.uri },
          { 'uri' => inaccessible_status.uri },
          { 'uri' => bookmarked.uri },
          { 'uri' => 'https://domain.unknown/foo' },
          { 'uri' => 'https://domain.unknown/private' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.bookmarks.create!(status: already_bookmarked)
        account.bookmarks.create!(status: bookmarked)
      end

      it 'enqueues workers for the expected rows and updates bookmarks' do
        subject.call(import)

        expect(row_worker_job_args)
          .to match_array(rows.map(&:id))

        stub_fetch_remote_and_drain_workers

        expect(account.bookmarks.map { |bookmark| bookmark.status.uri })
          .to contain_exactly(status.uri, bookmarked.uri, 'https://domain.unknown/foo')
      end
    end

    def row_worker_job_args
      Import::RowWorker
        .jobs
        .pluck('args')
        .flatten
    end

    def stub_resolve_account_and_drain_workers
      resolve_account_service_double = instance_double(ResolveAccountService)
      allow(ResolveAccountService)
        .to receive(:new)
        .and_return(resolve_account_service_double)
      allow(resolve_account_service_double)
        .to receive(:call)
        .with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
      allow(resolve_account_service_double)
        .to receive(:call)
        .with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

      Import::RowWorker.drain
    end

    def stub_fetch_remote_and_drain_workers
      service_double = instance_double(ActivityPub::FetchRemoteStatusService)
      allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(service_double)
      allow(service_double).to receive(:call).with('https://domain.unknown/foo') { Fabricate(:status, uri: 'https://domain.unknown/foo') }
      allow(service_double).to receive(:call).with('https://domain.unknown/private') { Fabricate(:status, uri: 'https://domain.unknown/private', visibility: :direct) }

      Import::RowWorker.drain
    end
  end
end
