# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveWorker do
  subject { described_class.new }

  let(:local_follower)   { Fabricate(:account, domain: nil) }
  let(:blocking_account) { Fabricate(:account) }
  let(:muting_account)   { Fabricate(:account) }
  let(:source_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com', uri: 'https://example.org/a', inbox_url: 'https://example.org/a/inbox') }
  let(:target_account)   { Fabricate(:account, protocol: :activitypub, domain: 'example.com', uri: 'https://example.org/b', inbox_url: 'https://example.org/b/inbox') }
  let(:local_user)       { Fabricate(:user) }
  let(:comment)          { 'old note prior to move' }
  let!(:account_note)    { Fabricate(:account_note, account: local_user.account, target_account: source_account, comment: comment) }
  let(:list)             { Fabricate(:list, account: local_follower) }

  let(:block_service) { instance_double(BlockService) }

  before do
    stub_request(:post, 'https://example.org/a/inbox').to_return(status: 200)
    stub_request(:post, 'https://example.org/b/inbox').to_return(status: 200)

    local_follower.follow!(source_account)
    blocking_account.block!(source_account)
    muting_account.mute!(source_account)

    list.accounts << source_account

    allow(BlockService).to receive(:new).and_return(block_service)
    allow(block_service).to receive(:call)
  end

  shared_examples 'user note handling' do
    context 'when user notes are short enough' do
      it 'copies user note with prelude' do
        subject.perform(source_account.id, target_account.id)
        expect(relevant_account_note.comment)
          .to include(source_account.acct, account_note.comment)
      end

      it 'merges user notes when needed' do
        new_account_note = AccountNote.create!(account: account_note.account, target_account: target_account, comment: 'new note prior to move')

        subject.perform(source_account.id, target_account.id)
        expect(relevant_account_note.comment)
          .to include(source_account.acct, account_note.comment, new_account_note.comment)
      end
    end

    context 'when user notes are too long' do
      let(:comment) { 'abc' * 333 }

      it 'copies user note without prelude' do
        subject.perform(source_account.id, target_account.id)
        expect(relevant_account_note.comment)
          .to include(account_note.comment)
      end

      it 'keeps user notes unchanged' do
        new_account_note = AccountNote.create!(account: account_note.account, target_account: target_account, comment: 'new note prior to move')

        subject.perform(source_account.id, target_account.id)
        expect(relevant_account_note.comment)
          .to include(new_account_note.comment)
      end
    end

    private

    def relevant_account_note
      AccountNote.find_by(account: account_note.account, target_account: target_account)
    end
  end

  shared_examples 'block and mute handling' do
    it 'makes blocks and mutes carry over and adds a note' do
      subject.perform(source_account.id, target_account.id)

      expect(block_service).to have_received(:call).with(blocking_account, target_account)
      expect(muting_account.muting?(target_account)).to be true

      expect(
        [note_account_comment, mute_account_comment]
      ).to all include(source_account.acct)
    end

    def note_account_comment
      AccountNote.find_by(account: blocking_account, target_account: target_account).comment
    end

    def mute_account_comment
      AccountNote.find_by(account: muting_account, target_account: target_account).comment
    end
  end

  shared_examples 'followers count handling' do
    it 'updates the source and target account followers counts' do
      subject.perform(source_account.id, target_account.id)

      expect(source_account.reload.followers_count).to eq(source_account.passive_relationships.count)
      expect(target_account.reload.followers_count).to eq(target_account.passive_relationships.count)
    end
  end

  shared_examples 'lists handling' do
    it 'puts the new account on the list and makes valid lists', :inline_jobs do
      subject.perform(source_account.id, target_account.id)

      expect(list.accounts.include?(target_account)).to be true
      expect(ListAccount.all).to all be_valid
    end
  end

  shared_examples 'common tests' do
    it_behaves_like 'user note handling'
    it_behaves_like 'block and mute handling'
    it_behaves_like 'followers count handling'
    it_behaves_like 'lists handling'

    context 'when a local user already follows both source and target' do
      before do
        local_follower.request_follow!(target_account)
      end

      it_behaves_like 'user note handling'
      it_behaves_like 'block and mute handling'
      it_behaves_like 'followers count handling'
      it_behaves_like 'lists handling'

      context 'when the local user already has the target in a list' do
        before do
          list.accounts << target_account
        end

        it_behaves_like 'lists handling'
      end
    end

    context 'when a local follower already has a pending request to the target' do
      before do
        local_follower.follow!(target_account)
      end

      it_behaves_like 'user note handling'
      it_behaves_like 'block and mute handling'
      it_behaves_like 'followers count handling'
      it_behaves_like 'lists handling'

      context 'when the local user already has the target in a list' do
        before do
          list.accounts << target_account
        end

        it_behaves_like 'lists handling'
      end
    end
  end

  describe '#perform' do
    context 'when both accounts are distant' do
      it 'calls UnfollowFollowWorker' do
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker).to have_enqueued_sidekiq_job(local_follower.id, source_account.id, target_account.id, false)
      end

      it_behaves_like 'common tests'
    end

    context 'when target account is local' do
      let(:target_account) { Fabricate(:account) }

      it 'calls UnfollowFollowWorker' do
        subject.perform(source_account.id, target_account.id)
        expect(UnfollowFollowWorker).to have_enqueued_sidekiq_job(local_follower.id, source_account.id, target_account.id, true)
      end

      it_behaves_like 'common tests'
    end

    context 'when both target and source accounts are local' do
      let(:target_account) { Fabricate(:account) }
      let(:source_account) { Fabricate(:account) }

      it 'calls makes local followers follow the target account' do
        subject.perform(source_account.id, target_account.id)
        expect(local_follower.following?(target_account)).to be true
      end

      it_behaves_like 'common tests'

      it 'does not allow the moved account to follow themselves' do
        source_account.follow!(target_account)
        subject.perform(source_account.id, target_account.id)
        expect(target_account.following?(target_account)).to be false
      end
    end
  end
end
