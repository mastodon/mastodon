# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountReachFinder do
  let(:account) { Fabricate(:account) }

  let(:ap_follower_example_com) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-1', domain: 'example.com') }
  let(:ap_follower_example_org) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.org/inbox-2', domain: 'example.org') }
  let(:ap_follower_with_shared) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/a/inbox', domain: 'foo.bar', shared_inbox_url: 'https://foo.bar/inbox') }

  let(:ap_mentioned_with_shared) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/b/inbox', domain: 'foo.bar', shared_inbox_url: 'https://foo.bar/inbox') }
  let(:ap_mentioned_example_com) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-3', domain: 'example.com') }
  let(:ap_mentioned_example_org) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.org/inbox-4', domain: 'example.org') }

  let(:unrelated_account) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/unrelated-inbox', domain: 'example.com') }

  before do
    ap_follower_example_com.follow!(account)
    ap_follower_example_org.follow!(account)
    ap_follower_with_shared.follow!(account)

    Fabricate(:status, account: account).tap do |status|
      status.mentions << Mention.new(account: ap_follower_example_com)
      status.mentions << Mention.new(account: ap_mentioned_with_shared)
    end

    Fabricate(:status, account: account)

    Fabricate(:status, account: account).tap do |status|
      status.mentions << Mention.new(account: ap_mentioned_example_com)
      status.mentions << Mention.new(account: ap_mentioned_example_org)
    end

    Fabricate(:status).tap do |status|
      status.mentions << Mention.new(account: unrelated_account)
    end
  end

  describe '#inboxes' do
    subject { described_class.new(account).inboxes }

    it 'includes the preferred inbox URL of followers and recently mentioned accounts but not unrelated users' do
      expect(subject)
        .to include(*follower_inbox_urls)
        .and include(*mentioned_account_inbox_urls)
        .and not_include(unrelated_account.preferred_inbox_url)
    end

    def follower_inbox_urls
      [ap_follower_example_com, ap_follower_example_org, ap_follower_with_shared]
        .map(&:preferred_inbox_url)
    end

    def mentioned_account_inbox_urls
      [ap_mentioned_with_shared, ap_mentioned_example_com, ap_mentioned_example_org]
        .map(&:preferred_inbox_url)
    end
  end
end
