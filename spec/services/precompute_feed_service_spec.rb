# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrecomputeFeedService do
  subject { PrecomputeFeedService.new }

  describe 'call' do
    let(:account) { Fabricate(:account) }
    it 'fills a user timeline with statuses' do
      account = Fabricate(:account)
      status = Fabricate(:status, account: account)

      subject.call(account)

      expect(Redis.current.zscore(FeedManager.instance.key(:home, account.id), status.id)).to be_within(0.1).of(status.id.to_f)
    end

    it 'does not raise an error even if it could not find any status' do
      account = Fabricate(:account)
      subject.call(account)
    end

    it 'filters statuses' do
      account = Fabricate(:account)
      muted_account = Fabricate(:account)
      Fabricate(:mute, account: account, target_account: muted_account)
      reblog = Fabricate(:status, account: muted_account)
      status = Fabricate(:status, account: account, reblog: reblog)

      subject.call(account)

      expect(Redis.current.zscore(FeedManager.instance.key(:home, account.id), reblog.id)).to eq nil
    end
  end
end
