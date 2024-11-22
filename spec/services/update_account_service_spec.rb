# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateAccountService do
  subject { described_class.new }

  describe 'switching form locked to unlocked accounts', :inline_jobs do
    let(:account) { Fabricate(:account, locked: true) }
    let(:alice)   { Fabricate(:account) }
    let(:bob)     { Fabricate(:account) }
    let(:eve)     { Fabricate(:account) }

    before do
      bob.touch(:silenced_at)
      account.mute!(eve)

      FollowService.new.call(alice, account)
      FollowService.new.call(bob, account)
      FollowService.new.call(eve, account)
    end

    it 'auto accepts pending follow requests from appropriate accounts' do
      subject.call(account, { locked: false })

      expect(alice).to be_following(account)
      expect(alice).to_not be_requested(account)

      expect(bob).to_not be_following(account)
      expect(bob).to be_requested(account)

      expect(eve).to be_following(account)
      expect(eve).to_not be_requested(account)
    end
  end
end
