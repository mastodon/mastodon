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
    around do |example|
      Sidekiq::Testing.fake! do
        example.run
        Sidekiq::Worker.clear_all
      end
    end

    context 'when importing follows' do
      let(:import_type) { 'following' }
      let(:overwrite)   { false }

      let!(:rows) do
        [
          { 'acct' => 'user@foo.bar' },
          { 'acct' => 'unknown@unknown.bar' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.follow!(Fabricate(:account))
      end

      it 'does not immediately change who the account follows' do
        expect { subject.call(import) }.to_not(change { account.reload.active_relationships.to_a })
      end

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows.map(&:id))
      end

      it 'requests to follow all the listed users once the workers have run' do
        subject.call(import)

        resolve_account_service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service_double)
        allow(resolve_account_service_double).to receive(:call).with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
        allow(resolve_account_service_double).to receive(:call).with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

        Import::RowWorker.drain

        expect(FollowRequest.includes(:target_account).where(account: account).map(&:target_account).map(&:acct)).to contain_exactly('user@foo.bar', 'unknown@unknown.bar')
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

      it 'unfollows user not present on list' do
        subject.call(import)
        expect(account.following?(to_be_unfollowed)).to be false
      end

      it 'updates the existing follow relationship as expected' do
        expect { subject.call(import) }.to change { Follow.where(account: account, target_account: followed).pick(:show_reblogs, :notify, :languages) }.from([true, false, nil]).to([false, true, ['en']])
      end

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows[1..].map(&:id))
      end

      it 'requests to follow all the expected users once the workers have run' do
        subject.call(import)

        resolve_account_service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service_double)
        allow(resolve_account_service_double).to receive(:call).with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
        allow(resolve_account_service_double).to receive(:call).with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

        Import::RowWorker.drain

        expect(FollowRequest.includes(:target_account).where(account: account).map(&:target_account).map(&:acct)).to contain_exactly('user@foo.bar', 'unknown@unknown.bar')
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

      before do
        account.block!(Fabricate(:account, username: 'already_blocked', domain: 'remote.org'))
      end

      it 'does not immediately change who the account blocks' do
        expect { subject.call(import) }.to_not(change { account.reload.blocking.to_a })
      end

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows.map(&:id))
      end

      it 'blocks all the listed users once the workers have run' do
        subject.call(import)

        resolve_account_service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service_double)
        allow(resolve_account_service_double).to receive(:call).with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
        allow(resolve_account_service_double).to receive(:call).with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

        Import::RowWorker.drain

        expect(account.blocking.map(&:acct)).to contain_exactly('already_blocked@remote.org', 'user@foo.bar', 'unknown@unknown.bar')
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

      it 'unblocks user not present on list' do
        subject.call(import)
        expect(account.blocking?(to_be_unblocked)).to be false
      end

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows[1..].map(&:id))
      end

      it 'requests to follow all the expected users once the workers have run' do
        subject.call(import)

        resolve_account_service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service_double)
        allow(resolve_account_service_double).to receive(:call).with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
        allow(resolve_account_service_double).to receive(:call).with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

        Import::RowWorker.drain

        expect(account.blocking.map(&:acct)).to contain_exactly('blocked@foo.bar', 'user@foo.bar', 'unknown@unknown.bar')
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

      before do
        account.mute!(Fabricate(:account, username: 'already_muted', domain: 'remote.org'))
      end

      it 'does not immediately change who the account blocks' do
        expect { subject.call(import) }.to_not(change { account.reload.muting.to_a })
      end

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows.map(&:id))
      end

      it 'mutes all the listed users once the workers have run' do
        subject.call(import)

        resolve_account_service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service_double)
        allow(resolve_account_service_double).to receive(:call).with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
        allow(resolve_account_service_double).to receive(:call).with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

        Import::RowWorker.drain

        expect(account.muting.map(&:acct)).to contain_exactly('already_muted@remote.org', 'user@foo.bar', 'unknown@unknown.bar')
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

      it 'updates the existing mute as expected' do
        expect { subject.call(import) }.to change { Mute.where(account: account, target_account: muted).pick(:hide_notifications) }.from(false).to(true)
      end

      it 'unblocks user not present on list' do
        subject.call(import)
        expect(account.muting?(to_be_unmuted)).to be false
      end

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows[1..].map(&:id))
      end

      it 'requests to follow all the expected users once the workers have run' do
        subject.call(import)

        resolve_account_service_double = instance_double(ResolveAccountService)
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service_double)
        allow(resolve_account_service_double).to receive(:call).with('user@foo.bar', any_args) { Fabricate(:account, username: 'user', domain: 'foo.bar', protocol: :activitypub) }
        allow(resolve_account_service_double).to receive(:call).with('unknown@unknown.bar', any_args) { Fabricate(:account, username: 'unknown', domain: 'unknown.bar', protocol: :activitypub) }

        Import::RowWorker.drain

        expect(account.muting.map(&:acct)).to contain_exactly('muted@foo.bar', 'user@foo.bar', 'unknown@unknown.bar')
      end
    end

    context 'when importing domain blocks' do
      let(:import_type) { 'domain_blocking' }
      let(:overwrite)   { false }

      let!(:rows) do
        [
          { 'domain' => 'blocked.com' },
          { 'domain' => 'to_block.com' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.block_domain!('alreadyblocked.com')
        account.block_domain!('blocked.com')
      end

      it 'blocks all the new domains' do
        subject.call(import)
        expect(account.domain_blocks.pluck(:domain)).to contain_exactly('alreadyblocked.com', 'blocked.com', 'to_block.com')
      end

      it 'marks the import as finished' do
        subject.call(import)
        expect(import.reload.finished?).to be true
      end
    end

    context 'when importing domain blocks with overwrite' do
      let(:import_type) { 'domain_blocking' }
      let(:overwrite)   { true }

      let!(:rows) do
        [
          { 'domain' => 'blocked.com' },
          { 'domain' => 'to_block.com' },
        ].map { |data| import.rows.create!(data: data) }
      end

      before do
        account.block_domain!('alreadyblocked.com')
        account.block_domain!('blocked.com')
      end

      it 'blocks all the new domains' do
        subject.call(import)
        expect(account.domain_blocks.pluck(:domain)).to contain_exactly('blocked.com', 'to_block.com')
      end

      it 'marks the import as finished' do
        subject.call(import)
        expect(import.reload.finished?).to be true
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

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows.map(&:id))
      end

      it 'updates the bookmarks as expected once the workers have run' do
        subject.call(import)

        service_double = instance_double(ActivityPub::FetchRemoteStatusService)
        allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:call).with('https://domain.unknown/foo') { Fabricate(:status, uri: 'https://domain.unknown/foo') }
        allow(service_double).to receive(:call).with('https://domain.unknown/private') { Fabricate(:status, uri: 'https://domain.unknown/private', visibility: :direct) }

        Import::RowWorker.drain

        expect(account.bookmarks.map(&:status).map(&:uri)).to contain_exactly(already_bookmarked.uri, status.uri, bookmarked.uri, 'https://domain.unknown/foo')
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

      it 'enqueues workers for the expected rows' do
        subject.call(import)
        expect(Import::RowWorker.jobs.pluck('args').flatten).to match_array(rows.map(&:id))
      end

      it 'updates the bookmarks as expected once the workers have run' do
        subject.call(import)

        service_double = instance_double(ActivityPub::FetchRemoteStatusService)
        allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:call).with('https://domain.unknown/foo') { Fabricate(:status, uri: 'https://domain.unknown/foo') }
        allow(service_double).to receive(:call).with('https://domain.unknown/private') { Fabricate(:status, uri: 'https://domain.unknown/private', visibility: :direct) }

        Import::RowWorker.drain

        expect(account.bookmarks.map(&:status).map(&:uri)).to contain_exactly(status.uri, bookmarked.uri, 'https://domain.unknown/foo')
      end
    end
  end
end
