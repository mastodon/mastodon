# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnfollowService do
  subject { described_class.new }

  let(:follower) { Fabricate(:account) }
  let(:followee) { Fabricate(:account) }

  before do
    follower.follow!(followee)
  end

  describe 'a local user unfollowing another local user' do
    it 'destroys the following relation' do
      expect { subject.call(follower, followee) }
        .to change { follower.following?(followee) }.from(true).to(false)
    end
  end

  describe 'a local user unfollowing a remote ActivityPub user' do
    let(:followee) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    it 'destroys the following relation and sends undo activity' do
      expect { subject.call(follower, followee) }
        .to change { follower.following?(followee) }.from(true).to(false)
        .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Undo'), follower.id, followee.inbox_url)
    end
  end

  describe 'a remote ActivityPub user unfollowing a local user' do
    let(:follower) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    it 'destroys the following relation and sends a reject activity' do
      expect { subject.call(follower, followee) }
        .to change { follower.following?(followee) }.from(true).to(false)
        .and enqueue_sidekiq_job(ActivityPub::DeliveryWorker).with(match_json_values(type: 'Reject'), followee.id, follower.inbox_url)
    end
  end
end
