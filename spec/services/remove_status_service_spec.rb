# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveStatusService, :inline_jobs do
  subject { described_class.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com') }
  let!(:jeff)   { Fabricate(:account) }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
  let!(:bill)   { Fabricate(:account, username: 'bill', protocol: :activitypub, domain: 'example2.com', inbox_url: 'http://example2.com/inbox') }

  before do
    stub_request(:post, hank.inbox_url).to_return(status: 200)
    stub_request(:post, bill.inbox_url).to_return(status: 200)

    jeff.follow!(alice)
    hank.follow!(alice)
  end

  context 'when removed status is not a reblog' do
    let!(:media_attachment) { Fabricate(:media_attachment, account: alice) }
    let!(:status) { PostStatusService.new.call(alice, text: "Hello @#{bob.pretty_acct} ThisIsASecret", media_ids: [media_attachment.id]) }

    before do
      FavouriteService.new.call(jeff, status)
      Fabricate(:status, account: bill, reblog: status, uri: 'hoge')
    end

    it 'removes status from notifications and from author and local follower home feeds, publishes to media timeline, sends delete activities' do
      allow(redis).to receive(:publish).with(any_args)

      expect { subject.call(status) }
        .to remove_status_from_notifications

      expect(home_feed_ids(alice))
        .to_not include(status.id)
      expect(home_feed_ids(jeff))
        .to_not include(status.id)

      expect(redis)
        .to have_received(:publish).with('timeline:public:media', Oj.dump(event: :delete, payload: status.id.to_s))

      expect(delete_delivery(hank, status))
        .to have_been_made.once

      expect(delete_delivery(bill, status))
        .to have_been_made.once
    end

    def home_feed_ids(personage)
      HomeFeed
        .new(personage)
        .get(10)
        .pluck(:id)
    end

    def remove_status_from_notifications
      change { Notification.where(activity_type: 'Favourite', from_account: jeff, account: alice).count }
        .from(1)
        .to(0)
    end

    def delete_delivery(target, status)
      a_request(:post, target.inbox_url)
        .with(body: delete_activity_for(status))
    end

    def delete_activity_for(status)
      hash_including(
        'type' => 'Delete',
        'object' => {
          'type' => 'Tombstone',
          'id' => ActivityPub::TagManager.instance.uri_for(status),
          'atomUri' => OStatus::TagManager.instance.uri_for(status),
        }
      )
    end
  end

  context 'when removed status is a private self-reblog' do
    let!(:original_status) { Fabricate(:status, account: alice, text: 'Hello ThisIsASecret', visibility: :private) }
    let!(:status) { ReblogService.new.call(alice, original_status) }

    it 'sends Undo activity to followers' do
      subject.call(status)

      expect(undo_delivery(hank, original_status))
        .to have_been_made.once
    end
  end

  context 'when removed status is public self-reblog' do
    let!(:original_status) { Fabricate(:status, account: alice, text: 'Hello ThisIsASecret', visibility: :public) }
    let!(:status) { ReblogService.new.call(alice, original_status) }

    it 'sends Undo activity to followers' do
      subject.call(status)

      expect(undo_delivery(hank, original_status))
        .to have_been_made.once
    end
  end

  context 'when removed status is a reblog of a non-follower' do
    let!(:original_status) { Fabricate(:status, account: bill, text: 'Hello ThisIsASecret', visibility: :public) }
    let!(:status) { ReblogService.new.call(alice, original_status) }

    it 'sends Undo activity to followers' do
      subject.call(status)

      expect(undo_delivery(bill, original_status))
        .to have_been_made.once
    end
  end

  def undo_delivery(target, status)
    a_request(:post, target.inbox_url)
      .with(body: undo_activity_for(status))
  end

  def undo_activity_for(status)
    hash_including(
      'type' => 'Undo',
      'object' => hash_including(
        'type' => 'Announce',
        'object' => ActivityPub::TagManager.instance.uri_for(status)
      )
    )
  end
end
