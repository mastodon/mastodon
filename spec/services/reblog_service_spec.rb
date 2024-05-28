# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReblogService do
  let(:alice)  { Fabricate(:account, username: 'alice') }

  context 'when creates a reblog with appropriate visibility' do
    subject { described_class.new }

    let(:visibility)        { :public }
    let(:reblog_visibility) { :public }
    let(:status)            { Fabricate(:status, account: alice, visibility: visibility) }

    before do
      subject.call(alice, status, visibility: reblog_visibility)
    end

    describe 'boosting privately' do
      let(:reblog_visibility) { :private }

      it 'reblogs privately' do
        expect(status.reblogs.first.visibility).to eq 'private'
      end
    end

    describe 'public reblogs of private toots should remain private' do
      let(:visibility)        { :private }
      let(:reblog_visibility) { :public }

      it 'reblogs privately' do
        expect(status.reblogs.first.visibility).to eq 'private'
      end
    end
  end

  context 'with a mid creation data update' do
    let(:status) { Fabricate(:status, account: alice, visibility: :public, text: 'discard-status-text') }

    before do
      allow(status).to receive(:with_lock).and_yield
    end

    it 'creates a reblog using a row locked status' do
      expect { subject.call(alice, status) }
        .to change(Status, :count).by(1)
      expect(status)
        .to have_received(:with_lock)
      expect(latest_reblog_status)
        .to eq(status.reblogs.first)
    end

    def latest_reblog_status
      Status.where.not(reblog_of_id: nil).last
    end
  end

  context 'with ActivityPub' do
    subject { described_class.new }

    let(:bob)    { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
    let(:status) { Fabricate(:status, account: bob) }

    before do
      stub_request(:post, bob.inbox_url)
      allow(ActivityPub::DistributionWorker).to receive(:perform_async)
      subject.call(alice, status)
    end

    it 'creates a reblog' do
      expect(status.reblogs.count).to eq 1
    end

    describe 'after_create_commit :store_uri' do
      it 'keeps consistent reblog count' do
        expect(status.reblogs.count).to eq 1
      end
    end

    it 'distributes to followers' do
      expect(ActivityPub::DistributionWorker).to have_received(:perform_async)
    end
  end
end
