require 'rails_helper'

describe Scheduler::FeedCleanupScheduler do
  subject { described_class.new }

  let!(:active_user) { Fabricate(:user, current_sign_in_at: 2.days.ago) }
  let!(:inactive_user) { Fabricate(:user, current_sign_in_at: 22.days.ago) }

  it 'clears feeds of inactives' do
    Redis.current.zadd(feed_key_for(inactive_user), 1, 1)
    Redis.current.zadd(feed_key_for(active_user), 1, 1)
    Redis.current.zadd(feed_key_for(inactive_user, 'reblogs'), 2, 2)
    Redis.current.sadd(feed_key_for(inactive_user, 'reblogs:2'), 3)

    subject.perform

    expect(Redis.current.zcard(feed_key_for(inactive_user))).to eq 0
    expect(Redis.current.zcard(feed_key_for(active_user))).to eq 1
    expect(Redis.current.exists(feed_key_for(inactive_user, 'reblogs'))).to be false
    expect(Redis.current.exists(feed_key_for(inactive_user, 'reblogs:2'))).to be false
  end

  def feed_key_for(user, subtype = nil)
    FeedManager.instance.key(:home, user.account_id, subtype)
  end
end
