# frozen_string_literal: true

require 'rails_helper'

describe MoveWorker do
  subject { described_class.new }

  let(:local_follower)   { Fabricate(:account) }
  let(:blocking_account) { Fabricate(:account) }
  let(:muting_account)   { Fabricate(:account) }
  let(:source_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com') }
  let(:target_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com') }
  let(:local_user)       { Fabricate(:user) }
  let(:comment)          { 'old note prior to move' }
  let!(:account_note)    { Fabricate(:account_note, account: local_user.account, target_account: source_account, comment: comment) }

  let(:block_service) { double }

  around(:each) do |example|
    Sidekiq::Testing.fake! do
      example.run
      Sidekiq::Worker.clear_all
    end
  end

  before do
    local_follower.follow!(source_account)
    blocking_account.block!(source_account)
    muting_account.mute!(source_account)

    allow(BlockService).to receive(:new).and_return(block_service)
    allow(block_service).to receive(:call)
  end

  shared_examples 'user note handling' do
    context 'when user notes are short enough' do
      it 'copies user note with prelude' do
        subject.perform(source_account.id, target_account.id)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(source_account.acct)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(account_note.comment)
      end

      it 'merges user notes when needed' do
        new_account_note = AccountNote.create!(account: account_note.account, target_account: target_account, comment: 'new note prior to move')

        subject.perform(source_account.id, target_account.id)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(source_account.acct)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(account_note.comment)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(new_account_note.comment)
      end
    end

    context 'when user notes are too long' do
      let(:comment) { 'abc' * 333 }

      it 'copies user note without prelude' do
        subject.perform(source_account.id, target_account.id)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(account_note.comment)
      end

      it 'keeps user notes unchanged' do
        new_account_note = AccountNote.create!(account: account_note.account, target_account: target_account, comment: 'new note prior to move')

        subject.perform(source_account.id, target_account.id)
        expect(AccountNote.find_by(account: account_note.account, target_account: target_account).comment).to include(new_account_note.comment)
      end
    end
  end

  shared_examples 'block and mute handling' do
    it 'makes blocks carry over and add a note' do
      subject.perform(source_account.id, target_account.id)
      expect(block_service).to have_received(:call).with(blocking_account, target_account)
      expect(AccountNote.find_by(account: blocking_account, target_account: target_account).comment).to include(source_account.acct)
    end

    it 'makes mutes carry over and add a note' do
      subject.perform(source_account.id, target_account.id)
      expect(muting_account.muting?(target_account)).to be true
      expect(AccountNote.find_by(account: muting_account, target_account: target_account).comment).to include(source_account.acct)
    end
  end

  shared_examples 'followers count handling' do
    it 'updates the source account followers count' do
      subject.perform(source_account.id, target_account.id)
      expect(source_account.reload.followers_count).to eq(source_account.passive_relationships.count)
    end

    it 'updates the target account followers count' do
      subject.perform(source_account.id, target_account.id)
      expect(target_account.reload.followers_count).to eq(target_account.passive_relationships.count)
    end
  end

  context 'both accounts are distant' do
    describe 'perform' do
      it 'calls UnfollowFollowWorker' do
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker.jobs.map { |job| job['args'] }).to match_array([[local_follower.id, source_account.id, target_account.id, false]])
      end

      include_examples 'user note handling'
      include_examples 'block and mute handling'
      include_examples 'followers count handling'
    end
  end

  context 'target account is local' do
    let(:target_account) { Fabricate(:account) }

    describe 'perform' do
      it 'calls UnfollowFollowWorker' do
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker.jobs.map { |job| job['args'] }).to match_array([[local_follower.id, source_account.id, target_account.id, true]])
      end

      include_examples 'user note handling'
      include_examples 'block and mute handling'
      include_examples 'followers count handling'
    end
  end

  context 'both target and source accounts are local' do
    let(:target_account) { Fabricate(:account) }
    let(:source_account) { Fabricate(:account) }

    describe 'perform' do
      it 'calls makes local followers follow the target account' do
        subject.perform(source_account.id, target_account.id)
        expect(local_follower.following?(target_account)).to be true
      end

      include_examples 'user note handling'
      include_examples 'block and mute handling'
      include_examples 'followers count handling'

      it 'does not fail when a local user is already following both accounts' do
        double_follower = Fabricate(:account)
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
