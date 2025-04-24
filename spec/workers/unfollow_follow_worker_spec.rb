# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnfollowFollowWorker do
  subject { described_class.new }

  let(:local_follower)   { Fabricate(:account) }
  let(:source_account)   { Fabricate(:account) }
  let(:target_account)   { Fabricate(:account) }
  let(:show_reblogs)     { true }

  before do
    local_follower.follow!(source_account, reblogs: show_reblogs)
  end

  context 'when show_reblogs is true' do
    let(:show_reblogs) { true }

    describe 'perform' do
      it 'unfollows source account and follows target account and preserves show_reblogs' do
        subject.perform(local_follower.id, source_account.id, target_account.id)
        expect(local_follower.following?(source_account)).to be false
        expect(local_follower.following?(target_account)).to be true

        expect(Follow.find_by(account: local_follower, target_account: target_account).show_reblogs?).to be show_reblogs
      end
    end
  end

  context 'when show_reblogs is false' do
    let(:show_reblogs) { false }

    describe 'perform' do
      it 'unfollows source account and follows target account and preserves show_reblogs' do
        subject.perform(local_follower.id, source_account.id, target_account.id)
        expect(local_follower.following?(source_account)).to be false
        expect(local_follower.following?(target_account)).to be true

        expect(Follow.find_by(account: local_follower, target_account: target_account).show_reblogs?).to be show_reblogs
      end
    end
  end
end
