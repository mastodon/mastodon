# frozen_string_literal: true

require 'rails_helper'

describe MoveWorker do
  let(:local_follower)   { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }
  let(:source_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com') }
  let(:target_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com') }

  subject { described_class.new }

  before do
    local_follower.follow!(source_account)
  end

  context 'both accounts are distant' do
    describe 'perform' do
      it 'calls UnfollowFollowWorker' do
        allow(UnfollowFollowWorker).to receive(:push_bulk)
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker).to have_received(:push_bulk).with([local_follower.id])
      end
    end
  end

  context 'target account is local' do
    let(:target_account) { Fabricate(:user, email: 'alice@example.com', account: Fabricate(:account, username: 'alice')).account }

    describe 'perform' do
      it 'calls UnfollowFollowWorker' do
        allow(UnfollowFollowWorker).to receive(:push_bulk)
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker).to have_received(:push_bulk).with([local_follower.id])
      end
    end
  end

  context 'both target and source accounts are local' do
    let(:target_account) { Fabricate(:user, email: 'alice@example.com', account: Fabricate(:account, username: 'alice')).account }
    let(:source_account) { Fabricate(:user, email: 'alice_@example.com', account: Fabricate(:account, username: 'alice_')).account }

    describe 'perform' do
      it 'calls makes local followers follow the target account' do
        subject.perform(source_account.id, target_account.id)
        expect(local_follower.following?(target_account)).to be true
      end

      it 'does not fail when a local user is already following both accounts' do
        double_follower = Fabricate(:user, email: 'eve@example.com', account: Fabricate(:account, username: 'eve')).account
        double_follower.follow!(source_account)
        double_follower.follow!(target_account)
        subject.perform(source_account.id, target_account.id)
        expect(local_follower.following?(target_account)).to be true
      end

      it 'does not allow the moved account to follow themselves' do
        source_account.follow!(target_account)
        subject.perform(source_account.id, target_account.id)
        expect(target_account.following?(target_account)).to be false
      end
    end
  end
end
