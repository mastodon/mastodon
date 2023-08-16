# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountReachFinder do
  let(:account) { Fabricate(:account) }

  let(:follower1) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-1') }
  let(:follower2) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-2') }
  let(:follower3) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/a/inbox', shared_inbox_url: 'https://foo.bar/inbox') }

  let(:mentioned1) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/b/inbox', shared_inbox_url: 'https://foo.bar/inbox') }
  let(:mentioned2) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-3') }
  let(:mentioned3) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-4') }

  let(:unrelated_account) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/unrelated-inbox') }

  before do
    follower1.follow!(account)
    follower2.follow!(account)
    follower3.follow!(account)

    Fabricate(:status, account: account).tap do |status|
      status.mentions << Mention.new(account: follower1)
      status.mentions << Mention.new(account: mentioned1)
    end

    Fabricate(:status, account: account)

    Fabricate(:status, account: account).tap do |status|
      status.mentions << Mention.new(account: mentioned2)
      status.mentions << Mention.new(account: mentioned3)
    end

    Fabricate(:status).tap do |status|
      status.mentions << Mention.new(account: unrelated_account)
    end
  end

  describe '#inboxes' do
    it 'includes the preferred inbox URL of followers' do
      expect(described_class.new(account).inboxes).to include(*[follower1, follower2, follower3].map(&:preferred_inbox_url))
    end

    it 'includes the preferred inbox URL of recently-mentioned accounts' do
      expect(described_class.new(account).inboxes).to include(*[mentioned1, mentioned2, mentioned3].map(&:preferred_inbox_url))
    end

    it 'does not include the inbox of unrelated users' do
      expect(described_class.new(account).inboxes).to_not include(unrelated_account.preferred_inbox_url)
    end
  end
end
