require 'rails_helper'

describe AccountInteractions do
  let(:account)            { Fabricate(:account, username: 'account') }
  let(:account_id)         { account.id }
  let(:account_ids)        { [account_id] }
  let(:target_account)     { Fabricate(:account, username: 'target') }
  let(:target_account_id)  { target_account.id }
  let(:target_account_ids) { [target_account_id] }

  describe '.following_map' do
    subject { Account.following_map(target_account_ids, account_id) }

    context 'account with Follow' do
      it 'returns { target_account_id => true }' do
        Fabricate(:follow, account: account, target_account: target_account)
        is_expected.to eq(target_account_id => { reblogs: true })
      end
    end

    context 'account without Follow' do
      it 'returns {}' do
        is_expected.to eq({})
      end
    end
  end

  describe '.followed_by_map' do
    subject { Account.followed_by_map(target_account_ids, account_id) }

    context 'account with Follow' do
      it 'returns { target_account_id => true }' do
        Fabricate(:follow, account: target_account, target_account: account)
        is_expected.to eq(target_account_id => true)
      end
    end

    context 'account without Follow' do
      it 'returns {}' do
        is_expected.to eq({})
      end
    end
  end

  describe '.blocking_map' do
    subject { Account.blocking_map(target_account_ids, account_id) }

    context 'account with Block' do
      it 'returns { target_account_id => true }' do
        Fabricate(:block, account: account, target_account: target_account)
        is_expected.to eq(target_account_id => true)
      end
    end

    context 'account without Block' do
      it 'returns {}' do
        is_expected.to eq({})
      end
    end
  end

  describe '.muting_map' do
    subject { Account.muting_map(target_account_ids, account_id) }

    context 'account with Mute' do
      before do
        Fabricate(:mute, target_account: target_account, account: account, hide_notifications: hide)
      end

      context 'if Mute#hide_notifications?' do
        let(:hide) { true }

        it 'returns { target_account_id => { notifications: true } }' do
          is_expected.to eq(target_account_id => { notifications: true })
        end
      end

      context 'unless Mute#hide_notifications?' do
        let(:hide) { false }

        it 'returns { target_account_id => { notifications: false } }' do
          is_expected.to eq(target_account_id => { notifications: false })
        end
      end
    end

    context 'account without Mute' do
      it 'returns {}' do
        is_expected.to eq({})
      end
    end
  end

  describe '#follow!' do
    it 'creates and returns Follow' do
      expect do
        expect(account.follow!(target_account)).to be_kind_of Follow
      end.to change { account.following.count }.by 1
    end
  end

  describe '#block' do
    it 'creates and returns Block' do
      expect do
        expect(account.block!(target_account)).to be_kind_of Block
      end.to change { account.block_relationships.count }.by 1
    end
  end

  describe '#mute!' do
    subject { account.mute!(target_account, notifications: arg_notifications) }

    context 'Mute does not exist yet' do
      context 'arg :notifications is nil' do
        let(:arg_notifications) { nil }

        it 'creates Mute, and returns Mute' do
          expect do
            expect(subject).to be_kind_of Mute
          end.to change { account.mute_relationships.count }.by 1
        end
      end

      context 'arg :notifications is false' do
        let(:arg_notifications) { false }

        it 'creates Mute, and returns Mute' do
          expect do
            expect(subject).to be_kind_of Mute
          end.to change { account.mute_relationships.count }.by 1
        end
      end

      context 'arg :notifications is true' do
        let(:arg_notifications) { true }

        it 'creates Mute, and returns Mute' do
          expect do
            expect(subject).to be_kind_of Mute
          end.to change { account.mute_relationships.count }.by 1
        end
      end
    end

    context 'Mute already exists' do
      before do
        account.mute_relationships << mute
      end

      let(:mute) do
        Fabricate(:mute,
                  account:            account,
                  target_account:     target_account,
                  hide_notifications: hide_notifications)
      end

      context 'mute.hide_notifications is true' do
        let(:hide_notifications) { true }

        context 'arg :notifications is nil' do
          let(:arg_notifications) { nil }

          it 'returns Mute without updating mute.hide_notifications' do
            expect do
              expect(subject).to be_kind_of Mute
            end.not_to change { mute.reload.hide_notifications? }.from(true)
          end
        end

        context 'arg :notifications is false' do
          let(:arg_notifications) { false }

          it 'returns Mute, and updates mute.hide_notifications false' do
            expect do
              expect(subject).to be_kind_of Mute
            end.to change { mute.reload.hide_notifications? }.from(true).to(false)
          end
        end

        context 'arg :notifications is true' do
          let(:arg_notifications) { true }

          it 'returns Mute without updating mute.hide_notifications' do
            expect do
              expect(subject).to be_kind_of Mute
            end.not_to change { mute.reload.hide_notifications? }.from(true)
          end
        end
      end

      context 'mute.hide_notifications is false' do
        let(:hide_notifications) { false }

        context 'arg :notifications is nil' do
          let(:arg_notifications) { nil }

          it 'returns Mute, and updates mute.hide_notifications true' do
            expect do
              expect(subject).to be_kind_of Mute
            end.to change { mute.reload.hide_notifications? }.from(false).to(true)
          end
        end

        context 'arg :notifications is false' do
          let(:arg_notifications) { false }

          it 'returns Mute without updating mute.hide_notifications' do
            expect do
              expect(subject).to be_kind_of Mute
            end.not_to change { mute.reload.hide_notifications? }.from(false)
          end
        end

        context 'arg :notifications is true' do
          let(:arg_notifications) { true }

          it 'returns Mute, and updates mute.hide_notifications true' do
            expect do
              expect(subject).to be_kind_of Mute
            end.to change { mute.reload.hide_notifications? }.from(false).to(true)
          end
        end
      end
    end
  end

  describe '#mute_conversation!' do
    let(:conversation) { Fabricate(:conversation) }

    subject { account.mute_conversation!(conversation) }

    it 'creates and returns ConversationMute' do
      expect do
        is_expected.to be_kind_of ConversationMute
      end.to change { account.conversation_mutes.count }.by 1
    end
  end

  describe '#block_domain!' do
    let(:domain_block) { Fabricate(:domain_block) }

    subject { account.block_domain!(domain_block) }

    it 'creates and returns AccountDomainBlock' do
      expect do
        is_expected.to be_kind_of AccountDomainBlock
      end.to change { account.domain_blocks.count }.by 1
    end
  end

  describe '#unfollow!' do
    subject { account.unfollow!(target_account) }

    context 'following target_account' do
      it 'returns destroyed Follow' do
        account.active_relationships.create(target_account: target_account)
        is_expected.to be_kind_of Follow
        expect(subject).to be_destroyed
      end
    end

    context 'not following target_account' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#unblock!' do
    subject { account.unblock!(target_account) }

    context 'blocking target_account' do
      it 'returns destroyed Block' do
        account.block_relationships.create(target_account: target_account)
        is_expected.to be_kind_of Block
        expect(subject).to be_destroyed
      end
    end

    context 'not blocking target_account' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#unmute!' do
    subject { account.unmute!(target_account) }

    context 'muting target_account' do
      it 'returns destroyed Mute' do
        account.mute_relationships.create(target_account: target_account)
        is_expected.to be_kind_of Mute
        expect(subject).to be_destroyed
      end
    end

    context 'not muting target_account' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#unmute_conversation!' do
    let(:conversation) { Fabricate(:conversation) }

    subject { account.unmute_conversation!(conversation) }

    context 'muting the conversation' do
      it 'returns destroyed ConversationMute' do
        account.conversation_mutes.create(conversation: conversation)
        is_expected.to be_kind_of ConversationMute
        expect(subject).to be_destroyed
      end
    end

    context 'not muting the conversation' do
      it 'returns nil' do
        is_expected.to be nil
      end
    end
  end

  describe '#unblock_domain!' do
    let(:domain) { 'example.com' }

    subject { account.unblock_domain!(domain) }

    context 'blocking the domain' do
      it 'returns destroyed AccountDomainBlock' do
        account_domain_block = Fabricate(:account_domain_block, domain: domain)
        account.domain_blocks << account_domain_block
        is_expected.to be_kind_of AccountDomainBlock
        expect(subject).to be_destroyed
      end
    end

    context 'unblocking the domain' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '#following?' do
    subject { account.following?(target_account) }

    context 'following target_account' do
      it 'returns true' do
        account.active_relationships.create(target_account: target_account)
        is_expected.to be true
      end
    end

    context 'not following target_account' do
      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#blocking?' do
    subject { account.blocking?(target_account) }

    context 'blocking target_account' do
      it 'returns true' do
        account.block_relationships.create(target_account: target_account)
        is_expected.to be true
      end
    end

    context 'not blocking target_account' do
      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#domain_blocking?' do
    let(:domain)               { 'example.com' }

    subject { account.domain_blocking?(domain) }

    context 'blocking the domain' do
      it' returns true' do
        account_domain_block = Fabricate(:account_domain_block, domain: domain)
        account.domain_blocks << account_domain_block
        is_expected.to be true
      end
    end

    context 'not blocking the domain' do
      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#muting?' do
    subject { account.muting?(target_account) }

    context 'muting target_account' do
      it 'returns true' do
        mute = Fabricate(:mute, account: account, target_account: target_account)
        account.mute_relationships << mute
        is_expected.to be true
      end
    end

    context 'not muting target_account' do
      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#muting_conversation?' do
    let(:conversation) { Fabricate(:conversation) }

    subject { account.muting_conversation?(conversation) }

    context 'muting the conversation' do
      it 'returns true' do
        account.conversation_mutes.create(conversation: conversation)
        is_expected.to be true
      end
    end

    context 'not muting the conversation' do
      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#muting_notifications?' do
    before do
      mute = Fabricate(:mute, target_account: target_account, account: account, hide_notifications: hide)
      account.mute_relationships << mute
    end

    subject { account.muting_notifications?(target_account) }

    context 'muting notifications of target_account' do
      let(:hide) { true }

      it 'returns true' do
        is_expected.to be true
      end
    end

    context 'not muting notifications of target_account' do
      let(:hide) { false }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#requested?' do
    subject { account.requested?(target_account) }

    context 'requested by target_account' do
      it 'returns true' do
        Fabricate(:follow_request, account: account, target_account: target_account)
        is_expected.to be true
      end
    end

    context 'not requested by target_account' do
      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#favourited?' do
    let(:status) { Fabricate(:status, account: account, favourites: favourites) }

    subject { account.favourited?(status) }

    context 'favorited' do
      let(:favourites) { [Fabricate(:favourite, account: account)] }

      it 'returns true' do
        is_expected.to be true
      end
    end

    context 'not favorited' do
      let(:favourites) { [] }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#reblogged?' do
    let(:status) { Fabricate(:status, account: account, reblogs: reblogs) }

    subject { account.reblogged?(status) }

    context 'reblogged' do
      let(:reblogs) { [Fabricate(:status, account: account)] }

      it 'returns true' do
        is_expected.to be true
      end
    end

    context 'not reblogged' do
      let(:reblogs) { [] }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe '#pinned?' do
    let(:status) { Fabricate(:status, account: account) }

    subject { account.pinned?(status) }

    context 'pinned' do
      it 'returns true' do
        Fabricate(:status_pin, account: account, status: status)
        is_expected.to be true
      end
    end

    context 'not pinned' do
      it 'returns false' do
        is_expected.to be false
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
    before do
      @me = Fabricate(:account, username: 'Me')
      @you = Fabricate(:account, username: 'You')
    end

    context 'with the reblogs option unspecified' do
      before do
        @me.follow!(@you)
      end

      it 'defaults to showing reblogs' do
        expect(@me.muting_reblogs?(@you)).to be(false)
      end
    end

    context 'with the reblogs option set to false' do
      before do
        @me.follow!(@you, reblogs: false)
      end

      it 'does mute reblogs' do
        expect(@me.muting_reblogs?(@you)).to be(true)
      end
    end

    context 'with the reblogs option set to true' do
      before do
        @me.follow!(@you, reblogs: true)
      end

      it 'does not mute reblogs' do
        expect(@me.muting_reblogs?(@you)).to be(false)
      end
    end
  end
end
