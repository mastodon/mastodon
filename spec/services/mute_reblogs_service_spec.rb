require 'rails_helper'

RSpec.describe MuteReblogsService do
  subject do
    -> { described_class.new.call(account, target_account) }
  end

  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'home timeline' do
    let(:status_by_target) { Fabricate(:status, account: target_account) }
    let(:other_account_status) { Fabricate(:status) }

    let(:reblogged_status_by_target) { Fabricate(:status, account: target_account) }
    let(:reblogged_other_account_status) { Fabricate(:status) }

    let(:reblog_of_target) { Fabricate(:status, reblog_of_id: reblogged_status_by_target.id) }
    let(:reblog_by_target) { Fabricate(:status, account: target_account, reblog_of_id: reblogged_other_account_status.id) }

    let(:home_timeline_key) { FeedManager.instance.key(:home, account.id) }

    before do
      Redis.current.del(home_timeline_key)
    end

    it "clears account's reblogs but not other statuses" do
      FeedManager.instance.push(:home, account, status_by_target)
      FeedManager.instance.push(:home, account, other_account_status)
      FeedManager.instance.push(:home, account, reblog_of_target)
      FeedManager.instance.push(:home, account, reblog_by_target)

      is_expected.to change {
        Redis.current.zrange(home_timeline_key, 0, -1)
      }
        .from([status_by_target.id.to_s, other_account_status.id.to_s, reblogged_status_by_target.id.to_s, reblogged_other_account_status.id.to_s])
        .to([status_by_target.id.to_s, other_account_status.id.to_s, reblogged_status_by_target.id.to_s])
    end
  end

  it 'mutes reblogs from account' do
    is_expected.to change {
      account.muting_reblogs?(target_account)
    }.from(false).to(true)
  end
end
