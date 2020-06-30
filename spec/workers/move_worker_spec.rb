# frozen_string_literal: true

require 'rails_helper'

describe MoveWorker do
  let(:local_follower)   { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }
  let(:source_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com') }
  let(:target_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com') }
  let(:local_user)       { Fabricate(:user) }
  let!(:account_note)    { Fabricate(:account_note, account: local_user.account, target_account: source_account) }

  subject { described_class.new }

  before do
    local_follower.follow!(source_account)
  end

  shared_examples 'user note handling' do
    it 'copies user note' do
      allow(UnfollowFollowWorker).to receive(:push_bulk)
      subject.perform(source_account.id, target_account.id)
      expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(source_account.acct)
      expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(account_note.comment)
    end

    it 'merges user notes when needed' do
      new_account_note = AccountNote.create!(account: account_note.account, target_account: target_account, comment: 'new note prior to move')

      allow(UnfollowFollowWorker).to receive(:push_bulk)
      subject.perform(source_account.id, target_account.id)
      expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(source_account.acct)
      expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(account_note.comment)
      expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(new_account_note.comment)
    end
  end

  context 'both accounts are distant' do
    describe 'perform' do
      it 'calls UnfollowFollowWorker' do
        allow(UnfollowFollowWorker).to receive(:push_bulk)
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker).to have_received(:push_bulk).with([local_follower.id])
      end

      include_examples 'user note handling'
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

      include_examples 'user note handling'
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

      include_examples 'user note handling'

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
