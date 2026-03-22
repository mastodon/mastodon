# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Interactions do
  let(:account)            { Fabricate(:account) }
  let(:target_account)     { Fabricate(:account) }

  describe '#blocking_or_domain_blocking?' do
    subject { account.blocking_or_domain_blocking?(target_account) }

    context 'when blocking target_account' do
      before do
        account.block_relationships.create(target_account: target_account)
      end

      it 'returns true' do
        result = nil
        expect { result = subject }.to execute_queries

        expect(result).to be true
      end
    end

    context 'when blocking the domain' do
      let(:target_account) { Fabricate(:remote_account) }

      before do
        account_domain_block = Fabricate(:account_domain_block, domain: target_account.domain)
        account.domain_blocks << account_domain_block
      end

      it 'returns true' do
        result = nil
        expect { result = subject }.to execute_queries
        expect(result).to be true
      end
    end

    context 'when blocking neither target_account nor its domain' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#muting_notifications?' do
    subject { account.muting_notifications?(target_account) }

    before do
      mute = Fabricate(:mute, target_account: target_account, account: account, hide_notifications: hide)
      account.mute_relationships << mute
    end

    context 'when muting notifications of target_account' do
      let(:hide) { true }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when not muting notifications of target_account' do
      let(:hide) { false }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#requested?' do
    subject { account.requested?(target_account) }

    context 'with requested by target_account' do
      it 'returns true' do
        Fabricate(:follow_request, account: account, target_account: target_account)
        expect(subject).to be true
      end
    end

    context 'when not requested by target_account' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#favourited?' do
    subject { account.favourited?(status) }

    let(:status) { Fabricate(:status, account: account, favourites: favourites) }

    context 'when favorited' do
      let(:favourites) { [Fabricate(:favourite, account: account)] }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when not favorited' do
      let(:favourites) { [] }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#reblogged?' do
    subject { account.reblogged?(status) }

    let(:status) { Fabricate(:status, account: account, reblogs: reblogs) }

    context 'with reblogged' do
      let(:reblogs) { [Fabricate(:status, account: account)] }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when not reblogged' do
      let(:reblogs) { [] }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#pinned?' do
    subject { account.pinned?(status) }

    let(:status) { Fabricate(:status, account: account) }

    context 'when pinned' do
      it 'returns true' do
        Fabricate(:status_pin, account: account, status: status)
        expect(subject).to be true
      end
    end

    context 'when not pinned' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe 'muting an account' do
    let(:me) { Fabricate(:account, username: 'Me') }
    let(:you) { Fabricate(:account, username: 'You') }

    context 'with the notifications option unspecified' do
      before do
        me.mute!(you)
      end

      it 'defaults to muting notifications' do
        expect(me.muting_notifications?(you)).to be true
      end
    end

    context 'with the notifications option set to false' do
      before do
        me.mute!(you, notifications: false)
      end

      it 'does not mute notifications' do
        expect(me.muting_notifications?(you)).to be false
      end
    end

    context 'with the notifications option set to true' do
      before do
        me.mute!(you, notifications: true)
      end

      it 'does mute notifications' do
        expect(me.muting_notifications?(you)).to be true
      end
    end
  end

  describe 'ignoring reblogs from an account' do
    let!(:me) { Fabricate(:account, username: 'Me') }
    let!(:you) { Fabricate(:account, username: 'You') }

    context 'with the reblogs option unspecified' do
      before do
        me.follow!(you)
      end

      it 'defaults to showing reblogs' do
        expect(me.muting_reblogs?(you)).to be(false)
      end
    end

    context 'with the reblogs option set to false' do
      before do
        me.follow!(you, reblogs: false)
      end

      it 'does mute reblogs' do
        expect(me.muting_reblogs?(you)).to be(true)
      end
    end

    context 'with the reblogs option set to true' do
      before do
        me.follow!(you, reblogs: true)
      end

      it 'does not mute reblogs' do
        expect(me.muting_reblogs?(you)).to be(false)
      end
    end
  end

  describe '#lists_for_local_distribution' do
    let(:account)                 { Fabricate(:user, current_sign_in_at: Time.now.utc).account }
    let!(:inactive_follower_user) { Fabricate(:user, current_sign_in_at: 5.years.ago) }
    let!(:follower_user)          { Fabricate(:user, current_sign_in_at: Time.now.utc) }
    let!(:follow_request_user)    { Fabricate(:user, current_sign_in_at: Time.now.utc) }

    let!(:inactive_follower_list) { Fabricate(:list, account: inactive_follower_user.account) }
    let!(:follower_list)          { Fabricate(:list, account: follower_user.account) }
    let!(:follow_request_list)    { Fabricate(:list, account: follow_request_user.account) }

    let!(:self_list)              { Fabricate(:list, account: account) }

    before do
      inactive_follower_user.account.follow!(account)
      follower_user.account.follow!(account)
      follow_request_user.account.follow_requests.create!(target_account: account)

      inactive_follower_list.accounts << account
      follower_list.accounts << account
      follow_request_list.accounts << account
      self_list.accounts << account
    end

    it 'includes only the list from the active follower and from oneself' do
      expect(account.lists_for_local_distribution.to_a).to contain_exactly(follower_list, self_list)
    end
  end
end
