require 'rails_helper'

describe Scheduler::FeedCleanupScheduler do
  subject { described_class.new }

  let!(:active_user) { Fabricate(:user, current_sign_in_at: 2.days.ago) }
  let!(:inactive_user) { Fabricate(:user, current_sign_in_at: 22.days.ago) }

  it 'clears feeds of inactives' do
    Redis.current.zadd(feed_key_for(inactive_user), 1, 1)
    Redis.current.zadd(feed_key_for(active_user), 1, 1)

    subject.perform

    expect(Redis.current.zcard(feed_key_for(inactive_user))).to eq 0
    expect(Redis.current.zcard(feed_key_for(active_user))).to eq 1
  end

  def feed_key_for(user)
    FeedManager.instance.key(:home, user.account_id)
  end
end
