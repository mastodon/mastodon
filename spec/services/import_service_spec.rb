require 'rails_helper'

RSpec.describe ImportService, type: :service do
  include RoutingHelper

  let!(:account) { Fabricate(:account, locked: false) }
  let!(:bob)     { Fabricate(:account, username: 'bob', locked: false) }
  let!(:eve)     { Fabricate(:account, username: 'eve', domain: 'example.com', locked: false, protocol: :activitypub, inbox_url: 'https://example.com/inbox') }

  before do
    stub_request(:post, "https://example.com/inbox").to_return(status: 200)
  end

  context 'import old-style list of muted users' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('mute-imports.txt') }

    describe 'when no accounts are muted' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }
      it 'mutes the listed accounts, including notifications' do
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
      end
    end

    describe 'when some accounts are muted and overwrite is not set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }

      it 'mutes the listed accounts, including notifications' do
        account.mute!(bob, notifications: false)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
      end
    end

    describe 'when some accounts are muted and overwrite is set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv, overwrite: true) }

      it 'mutes the listed accounts, including notifications' do
        account.mute!(bob, notifications: false)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
      end
    end
  end

  context 'import new-style list of muted users' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('new-mute-imports.txt') }

    describe 'when no accounts are muted' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }
      it 'mutes the listed accounts, respecting notifications' do
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
        expect(Mute.find_by(account: account, target_account: eve).hide_notifications).to be false
      end
    end

    describe 'when some accounts are muted and overwrite is not set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv) }

      it 'mutes the listed accounts, respecting notifications' do
        account.mute!(bob, notifications: true)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
        expect(Mute.find_by(account: account, target_account: eve).hide_notifications).to be false
      end
    end

    describe 'when some accounts are muted and overwrite is set' do
      let(:import) { Import.create(account: account, type: 'muting', data: csv, overwrite: true) }

      it 'mutes the listed accounts, respecting notifications' do
        account.mute!(bob, notifications: true)
        subject.call(import)
        expect(account.muting.count).to eq 2
        expect(Mute.find_by(account: account, target_account: bob).hide_notifications).to be true
        expect(Mute.find_by(account: account, target_account: eve).hide_notifications).to be false
      end
    end
  end

  context 'import old-style list of followed users' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('mute-imports.txt') }

    describe 'when no accounts are followed' do
      let(:import) { Import.create(account: account, type: 'following', data: csv) }
      it 'follows the listed accounts, including boosts' do
        subject.call(import)

        expect(account.following.count).to eq 1
        expect(account.follow_requests.count).to eq 1
        expect(Follow.find_by(account: account, target_account: bob).show_reblogs).to be true
      end
    end

    describe 'when some accounts are already followed and overwrite is not set' do
      let(:import) { Import.create(account: account, type: 'following', data: csv) }

      it 'follows the listed accounts, including notifications' do
        account.follow!(bob, reblogs: false)
        subject.call(import)
        expect(account.following.count).to eq 1
        expect(account.follow_requests.count).to eq 1
        expect(Follow.find_by(account: account, target_account: bob).show_reblogs).to be true
      end
    end

    describe 'when some accounts are already followed and overwrite is set' do
      let(:import) { Import.create(account: account, type: 'following', data: csv, overwrite: true) }

      it 'mutes the listed accounts, including notifications' do
        account.follow!(bob, reblogs: false)
        subject.call(import)
        expect(account.following.count).to eq 1
        expect(account.follow_requests.count).to eq 1
        expect(Follow.find_by(account: account, target_account: bob).show_reblogs).to be true
      end
    end
  end

  context 'import new-style list of followed users' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('new-following-imports.txt') }

    describe 'when no accounts are followed' do
      let(:import) { Import.create(account: account, type: 'following', data: csv) }
      it 'follows the listed accounts, respecting boosts' do
        subject.call(import)
        expect(account.following.count).to eq 1
        expect(account.follow_requests.count).to eq 1
        expect(Follow.find_by(account: account, target_account: bob).show_reblogs).to be true
        expect(FollowRequest.find_by(account: account, target_account: eve).show_reblogs).to be false
      end
    end

    describe 'when some accounts are already followed and overwrite is not set' do
      let(:import) { Import.create(account: account, type: 'following', data: csv) }

      it 'mutes the listed accounts, respecting notifications' do
        account.follow!(bob, reblogs: true)
        subject.call(import)
        expect(account.following.count).to eq 1
        expect(account.follow_requests.count).to eq 1
        expect(Follow.find_by(account: account, target_account: bob).show_reblogs).to be true
        expect(FollowRequest.find_by(account: account, target_account: eve).show_reblogs).to be false
      end
    end

    describe 'when some accounts are already followed and overwrite is set' do
      let(:import) { Import.create(account: account, type: 'following', data: csv, overwrite: true) }

      it 'mutes the listed accounts, respecting notifications' do
        account.follow!(bob, reblogs: true)
        subject.call(import)
        expect(account.following.count).to eq 1
        expect(account.follow_requests.count).to eq 1
        expect(Follow.find_by(account: account, target_account: bob).show_reblogs).to be true
        expect(FollowRequest.find_by(account: account, target_account: eve).show_reblogs).to be false
      end
    end
  end

  # Based on the bug report 20571 where UTF-8 encoded domains were rejecting import of their users
  #
  # https://github.com/mastodon/mastodon/issues/20571
  context 'utf-8 encoded domains' do
    subject { ImportService.new }

    let!(:nare)     { Fabricate(:account, username: 'nare', domain: 'թութ.հայ', locked: false, protocol: :activitypub, inbox_url: 'https://թութ.հայ/inbox') }

    # Make sure to not actually go to the remote server
    before do
      stub_request(:post, "https://թութ.հայ/inbox").to_return(status: 200)
    end

    let(:csv) { attachment_fixture('utf8-followers.txt') }
    let(:import) { Import.create(account: account, type: 'following', data: csv) }

    it 'follows the listed account' do
    expect(account.follow_requests.count).to eq 0
      subject.call(import)
      expect(account.follow_requests.count).to eq 1
    end
  end

  context 'import bookmarks' do
    subject { ImportService.new }

    let(:csv) { attachment_fixture('bookmark-imports.txt') }

    around(:each) do |example|
      local_before = Rails.configuration.x.local_domain
      web_before = Rails.configuration.x.web_domain
      Rails.configuration.x.local_domain = 'local.com'
      Rails.configuration.x.web_domain = 'local.com'
      example.run
      Rails.configuration.x.web_domain = web_before
      Rails.configuration.x.local_domain = local_before
    end

    let(:local_account)  { Fabricate(:account, username: 'foo', domain: '') }
    let!(:remote_status) { Fabricate(:status, uri: 'https://example.com/statuses/1312') }
    let!(:direct_status) { Fabricate(:status, uri: 'https://example.com/statuses/direct', visibility: :direct) }

    before do
      service = double
      allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(service)
      allow(service).to receive(:call).with('https://unknown-remote.com/users/bar/statuses/1') do
        Fabricate(:status, uri: 'https://unknown-remote.com/users/bar/statuses/1')
      end
    end

    describe 'when no bookmarks are set' do
      let(:import) { Import.create(account: account, type: 'bookmarks', data: csv) }
      it 'adds the toots the user has access to to bookmarks' do
        local_status = Fabricate(:status, account: local_account, uri: 'https://local.com/users/foo/statuses/42', id: 42, local: true)
        subject.call(import)
        expect(account.bookmarks.map(&:status).map(&:id)).to include(local_status.id)
        expect(account.bookmarks.map(&:status).map(&:id)).to include(remote_status.id)
        expect(account.bookmarks.map(&:status).map(&:id)).not_to include(direct_status.id)
        expect(account.bookmarks.count).to eq 3
      end
    end
  end
end
