require 'rails_helper'

RSpec.describe MuteService do
  subject do
    -> { described_class.new.call(account, target_account) }
  end

  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'home timeline' do
    let(:status) { Fabricate(:status, account: target_account) }
    let(:other_account_status) { Fabricate(:status) }
    let(:home_timeline_key) { FeedManager.instance.key(:home, account.id) }

    before do
      Redis.current.del(home_timeline_key)
    end

    it "clears account's statuses" do
      FeedManager.instance.push(:home, account, status)
      FeedManager.instance.push(:home, account, other_account_status)

      is_expected.to change {
        Redis.current.zrange(home_timeline_key, 0, -1)
      }.from([status.id.to_s, other_account_status.id.to_s]).to([other_account_status.id.to_s])
    end
  end

  it 'mutes account' do
    is_expected.to change {
      account.muting?(target_account)
    }.from(false).to(true)
  end
end
