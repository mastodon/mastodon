# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterBlockService, type: :service do
  subject { described_class.new.call(account, target_account) }

  let(:account)              { Fabricate(:account) }
  let(:target_account)       { Fabricate(:account) }
  let(:status)               { Fabricate(:status, account: target_account) }
  let(:other_status)         { Fabricate(:status, account: target_account) }
  let(:other_account_status) { Fabricate(:status) }
  let(:other_account_reblog) { Fabricate(:status, reblog_of_id: other_status.id) }

  describe 'home timeline' do
    let(:home_timeline_key) { FeedManager.instance.key(:home, account.id) }

    before do
      redis.del(home_timeline_key)
    end

    it "clears account's statuses" do
      FeedManager.instance.push_to_home(account, status)
      FeedManager.instance.push_to_home(account, other_account_status)
      FeedManager.instance.push_to_home(account, other_account_reblog)

      expect { subject }.to change {
        redis.zrange(home_timeline_key, 0, -1)
      }.from([status.id.to_s, other_account_status.id.to_s, other_account_reblog.id.to_s]).to([other_account_status.id.to_s])
    end
  end

  describe 'lists' do
    let(:list)              { Fabricate(:list, account: account) }
    let(:list_timeline_key) { FeedManager.instance.key(:list, list.id) }

    before do
      redis.del(list_timeline_key)
    end

    it "clears account's statuses" do
      FeedManager.instance.push_to_list(list, status)
      FeedManager.instance.push_to_list(list, other_account_status)
      FeedManager.instance.push_to_list(list, other_account_reblog)

      expect { subject }.to change {
        redis.zrange(list_timeline_key, 0, -1)
      }.from([status.id.to_s, other_account_status.id.to_s, other_account_reblog.id.to_s]).to([other_account_status.id.to_s])
    end
  end
end
