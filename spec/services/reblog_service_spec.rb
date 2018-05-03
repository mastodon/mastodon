require 'rails_helper'

RSpec.describe ReblogService, type: :service do
  let(:alice)  { Fabricate(:account, username: 'alice') }

  context 'OStatus' do
    let(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com') }
    let(:status) { Fabricate(:status, account: bob, uri: 'tag:example.com;something:something') }

    subject { ReblogService.new }

    before do
      stub_request(:post, 'http://salmon.example.com')
      subject.call(alice, status)
    end

    it 'creates a reblog' do
      expect(status.reblogs.count).to eq 1
    end

    it 'sends a Salmon slap for a remote reblog' do
      expect(a_request(:post, 'http://salmon.example.com')).to have_been_made
    end
  end

  context 'ActivityPub' do
    let(:bob)    { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
    let(:status) { Fabricate(:status, account: bob) }

    subject { ReblogService.new }

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

    it 'sends an announce activity to the author' do
      expect(a_request(:post, bob.inbox_url)).to have_been_made.once
    end
  end
end
