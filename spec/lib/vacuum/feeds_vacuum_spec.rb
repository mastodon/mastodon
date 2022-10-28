require 'rails_helper'

RSpec.describe Vacuum::FeedsVacuum do
  subject { described_class.new }

  describe '#perform' do
    let!(:active_user) { Fabricate(:user, current_sign_in_at: 2.days.ago) }
    let!(:inactive_user) { Fabricate(:user, current_sign_in_at: 22.days.ago) }

    before do
      redis.zadd(feed_key_for(inactive_user), 1, 1)
      redis.zadd(feed_key_for(active_user), 1, 1)
      redis.zadd(feed_key_for(inactive_user, 'reblogs'), 2, 2)
      redis.sadd(feed_key_for(inactive_user, 'reblogs:2'), 3)

      subject.perform
    end

    it 'clears feeds of inactive users and lists' do
      expect(redis.zcard(feed_key_for(inactive_user))).to eq 0
      expect(redis.zcard(feed_key_for(active_user))).to eq 1
      expect(redis.exists?(feed_key_for(inactive_user, 'reblogs'))).to be false
      expect(redis.exists?(feed_key_for(inactive_user, 'reblogs:2'))).to be false
    end
  end

  def feed_key_for(user, subtype = nil)
    FeedManager.instance.key(:home, user.account_id, subtype)
  end
end
