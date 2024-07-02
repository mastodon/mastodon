# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MuteService do
  subject { described_class.new.call(account, target_account) }

  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'home timeline' do
    let(:status) { Fabricate(:status, account: target_account) }
    let(:other_account_status) { Fabricate(:status) }
    let(:home_timeline_key) { FeedManager.instance.key(:home, account.id) }

    before do
      redis.del(home_timeline_key)
    end

    it "clears account's statuses", :inline_jobs do
      FeedManager.instance.push_to_home(account, status)
      FeedManager.instance.push_to_home(account, other_account_status)

      expect { subject }.to change {
        redis.zrange(home_timeline_key, 0, -1)
      }.from([status.id.to_s, other_account_status.id.to_s]).to([other_account_status.id.to_s])
    end
  end

  it 'mutes account' do
    expect { subject }.to change {
      account.muting?(target_account)
    }.from(false).to(true)
  end

  context 'without specifying a notifications parameter' do
    it 'mutes notifications from the account' do
      expect { subject }.to change {
        account.muting_notifications?(target_account)
      }.from(false).to(true)
    end
  end

  context 'with a true notifications parameter' do
    subject { described_class.new.call(account, target_account, notifications: true) }

    it 'mutes notifications from the account' do
      expect { subject }.to change {
        account.muting_notifications?(target_account)
      }.from(false).to(true)
    end
  end

  context 'with a false notifications parameter' do
    subject { described_class.new.call(account, target_account, notifications: false) }

    it 'does not mute notifications from the account' do
      expect { subject }.to_not change {
        account.muting_notifications?(target_account)
      }.from(false)
    end
  end
end
