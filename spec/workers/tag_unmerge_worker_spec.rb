# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagUnmergeWorker do
  subject { described_class.new }

  describe 'perform' do
    let(:follower)                { Fabricate(:account) }
    let(:followed)                { Fabricate(:account) }
    let(:followed_tag)            { Fabricate(:tag) }
    let(:unchanged_followed_tag)  { Fabricate(:tag) }
    let(:status_from_followed)    { Fabricate(:status, created_at: 2.hours.ago, account: followed) }
    let(:tagged_status)           { Fabricate(:status, created_at: 1.hour.ago) }
    let(:unchanged_tagged_status) { Fabricate(:status) }

    before do
      tagged_status.tags << followed_tag
      unchanged_tagged_status.tags << followed_tag
      unchanged_tagged_status.tags << unchanged_followed_tag

      tag_follow = TagFollow.create_with(rate_limit: false).find_or_create_by!(tag: followed_tag, account: follower)
      TagFollow.create_with(rate_limit: false).find_or_create_by!(tag: unchanged_followed_tag, account: follower)

      FeedManager.instance.push_to_home(follower, status_from_followed, update: false)
      FeedManager.instance.push_to_home(follower, tagged_status, update: false)
      FeedManager.instance.push_to_home(follower, unchanged_tagged_status, update: false)

      tag_follow.destroy!
    end

    it 'removes the expected status from the feed' do
      expect { subject.perform(followed_tag.id, follower.id) }
        .to change { HomeFeed.new(follower).get(10).pluck(:id) }
        .from([unchanged_tagged_status.id, tagged_status.id, status_from_followed.id])
        .to([unchanged_tagged_status.id, status_from_followed.id])
    end
  end
end
