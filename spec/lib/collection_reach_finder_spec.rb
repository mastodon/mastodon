# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionReachFinder do
  let(:account) { Fabricate(:account) }
  let(:collection) { Fabricate(:collection, account:) }

  let(:follower_example_com) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.com/inbox-1', domain: 'example.com') }
  let(:follower_with_shared) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/a/inbox', domain: 'foo.bar', shared_inbox_url: 'https://foo.bar/inbox') }

  let(:collection_member_with_shared) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://foo.bar/users/b/inbox', domain: 'foo.bar', shared_inbox_url: 'https://foo.bar/inbox') }
  let(:collection_member_example_org) { Fabricate(:account, protocol: :activitypub, inbox_url: 'https://example.org/inbox-2', domain: 'example.org') }

  before do
    follower_example_com.follow!(account)
    follower_with_shared.follow!(account)

    [follower_example_com, collection_member_with_shared, collection_member_example_org].each do |collection_member|
      Fabricate(:collection_item, collection:, account: collection_member, activity_uri: "https://#{collection_member.domain}/activity", approval_uri: "https://#{collection_member.domain}/approval")
    end
  end

  describe '#inboxes' do
    subject { described_class.new(collection).inboxes }

    it 'includes unique inbox URIs of followers and collection members respecting shared inbox URIs where present' do
      expect(subject).to contain_exactly(
        'https://example.com/inbox-1',
        'https://foo.bar/inbox',
        'https://example.org/inbox-2'
      )
    end
  end
end
