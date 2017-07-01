# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrecomputeFeedService do
  subject { PrecomputeFeedService.new }

  describe 'call' do
    let(:account) { Fabricate(:account) }
    it 'fills a user timeline with statuses' do
      account = Fabricate(:account)
      followed_account = Fabricate(:account)
      Fabricate(:follow, account: account, target_account: followed_account)
      reblog = Fabricate(:status, account: followed_account)
      status = Fabricate(:status, account: account, reblog: reblog)

      subject.call(account)

      expect(Redis.current.zscore(FeedManager.instance.key(:home, account.id), reblog.id)).to eq status.id
    end

    it 'does not raise an error even if it could not find any status' do
      account = Fabricate(:account)
      subject.call(account)
    end
  end
end
