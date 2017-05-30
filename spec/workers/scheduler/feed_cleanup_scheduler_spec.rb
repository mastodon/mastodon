require 'rails_helper'

describe Scheduler::FeedCleanupScheduler do
  subject { described_class.new }

  let!(:active_user) { Fabricate(:user, current_sign_in_at: 2.days.ago) }
  let!(:inactive_user) { Fabricate(:user, current_sign_in_at: 22.days.ago) }

  it 'clears feeds of inactives' do
    expect_any_instance_of(Redis).to receive(:del).with(feed_key_for(inactive_user))
    expect_any_instance_of(Redis).not_to receive(:del).with(feed_key_for(active_user))

    subject.perform
  end

  def feed_key_for(user)
    FeedManager.instance.key(:home, user.account_id)
  end
end
