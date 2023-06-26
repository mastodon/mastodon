# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveStatusService, type: :service do
  subject { described_class.new }

  let!(:alice)  { Fabricate(:account) }
  let!(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com') }
  let!(:jeff)   { Fabricate(:account) }
  let!(:hank)   { Fabricate(:account, username: 'hank', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
  let!(:bill)   { Fabricate(:account, username: 'bill', protocol: :activitypub, domain: 'example2.com', inbox_url: 'http://example2.com/inbox') }

  before do
    stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    stub_request(:post, 'http://example2.com/inbox').to_return(status: 200)

    jeff.follow!(alice)
    hank.follow!(alice)
  end

  context 'when removed status is not a reblog' do
    before do
      @status = PostStatusService.new.call(alice, text: 'Hello @bob@example.com ThisIsASecret')
      FavouriteService.new.call(jeff, @status)
      Fabricate(:status, account: bill, reblog: @status, uri: 'hoge')
    end

    it 'removes status from author\'s home feed' do
      subject.call(@status)
      expect(HomeFeed.new(alice).get(10)).to_not include(@status.id)
    end

    it 'removes status from local follower\'s home feed' do
      subject.call(@status)
      expect(HomeFeed.new(jeff).get(10)).to_not include(@status.id)
    end

    it 'sends Delete activity to followers' do
      subject.call(@status)
      expect(a_request(:post, 'http://example.com/inbox').with(
               body: hash_including({
                 'type' => 'Delete',
                 'object' => {
                   'type' => 'Tombstone',
                   'id' => ActivityPub::TagManager.instance.uri_for(@status),
                   'atomUri' => OStatus::TagManager.instance.uri_for(@status),
                 },
               })
             )).to have_been_made.once
    end

    it 'sends Delete activity to rebloggers' do
      subject.call(@status)
      expect(a_request(:post, 'http://example2.com/inbox').with(
               body: hash_including({
                 'type' => 'Delete',
                 'object' => {
                   'type' => 'Tombstone',
                   'id' => ActivityPub::TagManager.instance.uri_for(@status),
                   'atomUri' => OStatus::TagManager.instance.uri_for(@status),
                 },
               })
             )).to have_been_made.once
    end

    it 'remove status from notifications' do
      expect { subject.call(@status) }.to change {
        Notification.where(activity_type: 'Favourite', from_account: jeff, account: alice).count
      }.from(1).to(0)
    end
  end

  context 'when removed status is a private self-reblog' do
    before do
      @original_status = Fabricate(:status, account: alice, text: 'Hello ThisIsASecret', visibility: :private)
      @status = ReblogService.new.call(alice, @original_status)
    end

    it 'sends Undo activity to followers' do
      subject.call(@status)
      expect(a_request(:post, 'http://example.com/inbox').with(
               body: hash_including({
                 'type' => 'Undo',
                 'object' => hash_including({
                   'type' => 'Announce',
                   'object' => ActivityPub::TagManager.instance.uri_for(@original_status),
                 }),
               })
             )).to have_been_made.once
    end
  end

  context 'when removed status is public self-reblog' do
    before do
      @original_status = Fabricate(:status, account: alice, text: 'Hello ThisIsASecret', visibility: :public)
      @status = ReblogService.new.call(alice, @original_status)
    end

    it 'sends Undo activity to followers' do
      subject.call(@status)
      expect(a_request(:post, 'http://example.com/inbox').with(
               body: hash_including({
                 'type' => 'Undo',
                 'object' => hash_including({
                   'type' => 'Announce',
                   'object' => ActivityPub::TagManager.instance.uri_for(@original_status),
                 }),
               })
             )).to have_been_made.once
    end
  end
end
