# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnfollowService do
  subject { described_class.new }

  let(:follower) { Fabricate(:account) }
  let(:followee) { Fabricate(:account) }

  before do
    follower.follow!(followee)
  end

  shared_examples 'when the followee is in a list' do
    let(:list) { Fabricate(:list, account: follower) }

    before do
      list.accounts << followee
    end

    it 'schedules removal of posts from this user from the list' do
      expect { subject.call(follower, followee) }
        .to enqueue_sidekiq_job(UnmergeWorker).with(followee.id, list.id, 'list')
    end
  end

  describe 'a local user unfollowing another local user' do
    it 'destroys the following relation and unmerge from home' do
      expect { subject.call(follower, followee) }
        .to change { follower.following?(followee) }.from(true).to(false)
        .and enqueue_sidekiq_job(UnmergeWorker).with(followee.id, follower.id, 'home')
    end

    it_behaves_like 'when the followee is in a list'
  end

  describe 'a local user unfollowing a remote ActivityPub user' do
    let(:followee) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    it 'destroys the following relation, unmerge from home and sends undo activity' do
      expect { subject.call(follower, followee) }
        .to change { follower.following?(followee) }.from(true).to(false)
        .and enqueue_sidekiq_job(UnmergeWorker).with(followee.id, follower.id, 'home')
        .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Undo'), follower.id, followee.inbox_url)
    end

    it_behaves_like 'when the followee is in a list'
  end

  describe 'a remote ActivityPub user unfollowing a local user' do
    let(:follower) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    it 'destroys the following relation, unmerge from home and sends a reject activity' do
      expect { subject.call(follower, followee) }
        .to change { follower.following?(followee) }.from(true).to(false)
        .and enqueue_sidekiq_job(UnmergeWorker).with(followee.id, follower.id, 'home')
        .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Reject'), followee.id, follower.inbox_url)
    end
  end
end
