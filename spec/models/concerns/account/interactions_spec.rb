# frozen_string_literal: true

require 'rails_helper'

describe Account::Interactions do
  let(:account)            { Fabricate(:account, username: 'account') }
  let(:account_id)         { account.id }
  let(:account_ids)        { [account_id] }
  let(:target_account)     { Fabricate(:account, username: 'target') }
  let(:target_account_id)  { target_account.id }
  let(:target_account_ids) { [target_account_id] }

  describe '.following_map' do
    subject { Account.following_map(target_account_ids, account_id) }

    context 'when Account with Follow' do
      it 'returns { target_account_id => true }' do
        Fabricate(:follow, account: account, target_account: target_account)
        expect(subject).to eq(target_account_id => { reblogs: true, notify: false, languages: nil })
      end
    end

    context 'when Account with Follow but with reblogs disabled' do
      it 'returns { target_account_id => { reblogs: false } }' do
        Fabricate(:follow, account: account, target_account: target_account, show_reblogs: false)
        expect(subject).to eq(target_account_id => { reblogs: false, notify: false, languages: nil })
      end
    end

    context 'when Account without Follow' do
      it 'returns {}' do
        expect(subject).to eq({})
      end
    end
  end

  describe '.followed_by_map' do
    subject { Account.followed_by_map(target_account_ids, account_id) }

    context 'when Account with Follow' do
      it 'returns { target_account_id => true }' do
        Fabricate(:follow, account: target_account, target_account: account)
        expect(subject).to eq(target_account_id => true)
      end
    end

    context 'when Account without Follow' do
      it 'returns {}' do
        expect(subject).to eq({})
      end
    end
  end

  describe '.blocking_map' do
    subject { Account.blocking_map(target_account_ids, account_id) }

    context 'when Account with Block' do
      it 'returns { target_account_id => true }' do
        Fabricate(:block, account: account, target_account: target_account)
        expect(subject).to eq(target_account_id => true)
      end
    end

    context 'when Account without Block' do
      it 'returns {}' do
        expect(subject).to eq({})
      end
    end
  end

  describe '.muting_map' do
    subject { Account.muting_map(target_account_ids, account_id) }

    context 'when Account with Mute' do
      before do
        Fabricate(:mute, target_account: target_account, account: account, hide_notifications: hide)
      end

      context 'when Mute#hide_notifications?' do
        let(:hide) { true }

        it 'returns { target_account_id => { notifications: true } }' do
          expect(subject).to eq(target_account_id => { notifications: true })
        end
      end

      context 'when not Mute#hide_notifications?' do
        let(:hide) { false }

        it 'returns { target_account_id => { notifications: false } }' do
          expect(subject).to eq(target_account_id => { notifications: false })
        end
      end
    end

    context 'when Account without Mute' do
      it 'returns {}' do
        expect(subject).to eq({})
      end
    end
  end

  describe '#follow!' do
    it 'creates and returns Follow' do
      expect do
        expect(account.follow!(target_account)).to be_a Follow
      end.to change { account.following.count }.by 1
    end
  end

  describe '#block' do
    it 'creates and returns Block' do
      expect do
        expect(account.block!(target_account)).to be_a Block
      end.to change { account.block_relationships.count }.by 1
    end
  end

  describe '#mute!' do
    subject { account.mute!(target_account, notifications: arg_notifications) }

    context 'when Mute does not exist yet' do
      context 'when arg :notifications is nil' do
        let(:arg_notifications) { nil }

        it 'creates Mute, and returns Mute' do
          expect do
            expect(subject).to be_a Mute
          end.to change { account.mute_relationships.count }.by 1
        end
      end

      context 'when arg :notifications is false' do
        let(:arg_notifications) { false }

        it 'creates Mute, and returns Mute' do
          expect do
            expect(subject).to be_a Mute
          end.to change { account.mute_relationships.count }.by 1
        end
      end

      context 'when arg :notifications is true' do
        let(:arg_notifications) { true }

        it 'creates Mute, and returns Mute' do
          expect do
            expect(subject).to be_a Mute
          end.to change { account.mute_relationships.count }.by 1
        end
      end
    end

    context 'when Mute already exists' do
      before do
        account.mute_relationships << mute
      end

      let(:mute) do
        Fabricate(:mute,
                  account: account,
                  target_account: target_account,
                  hide_notifications: hide_notifications)
      end

      context 'when mute.hide_notifications is true' do
        let(:hide_notifications) { true }

        context 'when arg :notifications is nil' do
          let(:arg_notifications) { nil }

          it 'returns Mute without updating mute.hide_notifications' do
            expect do
              expect(subject).to be_a Mute
            end.to_not change { mute.reload.hide_notifications? }.from(true)
          end
        end

        context 'when arg :notifications is false' do
          let(:arg_notifications) { false }

          it 'returns Mute, and updates mute.hide_notifications false' do
            expect do
              expect(subject).to be_a Mute
            end.to change { mute.reload.hide_notifications? }.from(true).to(false)
          end
        end

        context 'when arg :notifications is true' do
          let(:arg_notifications) { true }

          it 'returns Mute without updating mute.hide_notifications' do
            expect do
              expect(subject).to be_a Mute
            end.to_not change { mute.reload.hide_notifications? }.from(true)
          end
        end
      end

      context 'when mute.hide_notifications is false' do
        let(:hide_notifications) { false }

        context 'when arg :notifications is nil' do
          let(:arg_notifications) { nil }

          it 'returns Mute, and updates mute.hide_notifications true' do
            expect do
              expect(subject).to be_a Mute
            end.to change { mute.reload.hide_notifications? }.from(false).to(true)
          end
        end

        context 'when arg :notifications is false' do
          let(:arg_notifications) { false }

          it 'returns Mute without updating mute.hide_notifications' do
            expect do
              expect(subject).to be_a Mute
            end.to_not change { mute.reload.hide_notifications? }.from(false)
          end
        end

        context 'when arg :notifications is true' do
          let(:arg_notifications) { true }

          it 'returns Mute, and updates mute.hide_notifications true' do
            expect do
              expect(subject).to be_a Mute
            end.to change { mute.reload.hide_notifications? }.from(false).to(true)
          end
        end
      end
    end
  end

  describe '#mute_conversation!' do
    subject { account.mute_conversation!(conversation) }

    let(:conversation) { Fabricate(:conversation) }

    it 'creates and returns ConversationMute' do
      expect do
        expect(subject).to be_a ConversationMute
      end.to change { account.conversation_mutes.count }.by 1
    end
  end

  describe '#block_domain!' do
    subject { account.block_domain!(domain) }

    let(:domain) { 'example.com' }

    it 'creates and returns AccountDomainBlock' do
      expect do
        expect(subject).to be_a AccountDomainBlock
      end.to change { account.domain_blocks.count }.by 1
    end
  end

  describe '#block_idna_domain!' do
    subject do
      [
        account.block_domain!(idna_domain),
        account.block_domain!(punycode_domain),
      ]
    end

    let(:idna_domain) { '대한민국.한국' }
    let(:punycode_domain) { 'xn--3e0bs9hfvinn1a.xn--3e0b707e' }

    it 'creates single AccountDomainBlock' do
      expect do
        expect(subject).to all(be_a AccountDomainBlock)
      end.to change { account.domain_blocks.count }.by 1
    end
  end

  describe '#unfollow!' do
    subject { account.unfollow!(target_account) }

    context 'when following target_account' do
      it 'returns destroyed Follow' do
        account.active_relationships.create(target_account: target_account)
        expect(subject).to be_a Follow
        expect(subject).to be_destroyed
      end
    end

    context 'when not following target_account' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#unblock!' do
    subject { account.unblock!(target_account) }

    context 'when blocking target_account' do
      it 'returns destroyed Block' do
        account.block_relationships.create(target_account: target_account)
        expect(subject).to be_a Block
        expect(subject).to be_destroyed
      end
    end

    context 'when not blocking target_account' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#unmute!' do
    subject { account.unmute!(target_account) }

    context 'when muting target_account' do
      it 'returns destroyed Mute' do
        account.mute_relationships.create(target_account: target_account)
        expect(subject).to be_a Mute
        expect(subject).to be_destroyed
      end
    end

    context 'when not muting target_account' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#unmute_conversation!' do
    subject { account.unmute_conversation!(conversation) }

    let(:conversation) { Fabricate(:conversation) }

    context 'when muting the conversation' do
      it 'returns destroyed ConversationMute' do
        account.conversation_mutes.create(conversation: conversation)
        expect(subject).to be_a ConversationMute
        expect(subject).to be_destroyed
      end
    end

    context 'when not muting the conversation' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#unblock_domain!' do
    subject { account.unblock_domain!(domain) }

    let(:domain) { 'example.com' }

    context 'when blocking the domain' do
      it 'returns destroyed AccountDomainBlock' do
        account_domain_block = Fabricate(:account_domain_block, domain: domain)
        account.domain_blocks << account_domain_block
        expect(subject).to be_a AccountDomainBlock
        expect(subject).to be_destroyed
      end
    end

    context 'when unblocking the domain' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#unblock_idna_domain!' do
    subject { account.unblock_domain!(punycode_domain) }

    let(:idna_domain) { '대한민국.한국' }
    let(:punycode_domain) { 'xn--3e0bs9hfvinn1a.xn--3e0b707e' }

    context 'when blocking the domain' do
      it 'returns destroyed AccountDomainBlock' do
        account_domain_block = Fabricate(:account_domain_block, domain: idna_domain)
        account.domain_blocks << account_domain_block
        expect(subject).to be_a AccountDomainBlock
        expect(subject).to be_destroyed
      end
    end

    context 'when unblocking idna domain' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#following?' do
    subject { account.following?(target_account) }

    context 'when following target_account' do
      it 'returns true' do
        account.active_relationships.create(target_account: target_account)
        expect(subject).to be true
      end
    end

    context 'when not following target_account' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#followed_by?' do
    subject { account.followed_by?(target_account) }

    context 'when followed by target_account' do
      it 'returns true' do
        account.passive_relationships.create(account: target_account)
        expect(subject).to be true
      end
    end

    context 'when not followed by target_account' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#blocking?' do
    subject { account.blocking?(target_account) }

    context 'when blocking target_account' do
      it 'returns true' do
        account.block_relationships.create(target_account: target_account)
        expect(subject).to be true
      end
    end

    context 'when not blocking target_account' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#domain_blocking?' do
    subject { account.domain_blocking?(domain) }

    let(:domain) { 'example.com' }

    context 'when blocking the domain' do
      it 'returns true' do
        account_domain_block = Fabricate(:account_domain_block, domain: domain)
        account.domain_blocks << account_domain_block
        expect(subject).to be true
      end
    end

    context 'when not blocking the domain' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#muting?' do
    subject { account.muting?(target_account) }

    context 'when muting target_account' do
      it 'returns true' do
        mute = Fabricate(:mute, account: account, target_account: target_account)
        account.mute_relationships << mute
        expect(subject).to be true
      end
    end

    context 'when not muting target_account' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#muting_conversation?' do
    subject { account.muting_conversation?(conversation) }

    let(:conversation) { Fabricate(:conversation) }

    context 'when muting the conversation' do
      it 'returns true' do
        account.conversation_mutes.create(conversation: conversation)
        expect(subject).to be true
      end
    end

    context 'when not muting the conversation' do
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

  describe '#remote_followers_hash' do
    let(:me) { Fabricate(:account, username: 'Me') }
    let(:remote_alice) { Fabricate(:account, username: 'alice', domain: 'example.org', uri: 'https://example.org/users/alice') }
    let(:remote_bob) { Fabricate(:account, username: 'bob', domain: 'example.org', uri: 'https://example.org/users/bob') }
    let(:remote_instance_actor) { Fabricate(:account, username: 'instance-actor', domain: 'example.org', uri: 'https://example.org') }
    let(:remote_eve) { Fabricate(:account, username: 'eve', domain: 'foo.org', uri: 'https://foo.org/users/eve') }

    before do
      remote_alice.follow!(me)
      remote_bob.follow!(me)
      remote_instance_actor.follow!(me)
      remote_eve.follow!(me)
      me.follow!(remote_alice)
    end

    it 'returns correct hash for remote domains' do
      expect(me.remote_followers_hash('https://example.org/')).to eq '20aecbe774b3d61c25094370baf370012b9271c5b172ecedb05caff8d79ef0c7'
      expect(me.remote_followers_hash('https://foo.org/')).to eq 'ccb9c18a67134cfff9d62c7f7e7eb88e6b803446c244b84265565f4eba29df0e'
      expect(me.remote_followers_hash('https://foo.org.evil.com/')).to eq '0000000000000000000000000000000000000000000000000000000000000000'
      expect(me.remote_followers_hash('https://foo')).to eq '0000000000000000000000000000000000000000000000000000000000000000'
    end

    it 'invalidates cache as needed when removing or adding followers' do
      expect(me.remote_followers_hash('https://example.org/')).to eq '20aecbe774b3d61c25094370baf370012b9271c5b172ecedb05caff8d79ef0c7'
      remote_instance_actor.unfollow!(me)
      expect(me.remote_followers_hash('https://example.org/')).to eq '707962e297b7bd94468a21bc8e506a1bcea607a9142cd64e27c9b106b2a5f6ec'
      remote_alice.unfollow!(me)
      expect(me.remote_followers_hash('https://example.org/')).to eq '241b00794ce9b46aa864f3220afadef128318da2659782985bac5ed5bd436bff'
      remote_alice.follow!(me)
      expect(me.remote_followers_hash('https://example.org/')).to eq '707962e297b7bd94468a21bc8e506a1bcea607a9142cd64e27c9b106b2a5f6ec'
    end
  end

  describe '#local_followers_hash' do
    let(:me) { Fabricate(:account, username: 'Me') }
    let(:remote_alice) { Fabricate(:account, username: 'alice', domain: 'example.org', uri: 'https://example.org/users/alice') }

    before do
      me.follow!(remote_alice)
    end

    it 'returns correct hash for local users' do
      expect(remote_alice.local_followers_hash).to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
    end

    it 'invalidates cache as needed when removing or adding followers' do
      expect(remote_alice.local_followers_hash).to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
      me.unfollow!(remote_alice)
      expect(remote_alice.local_followers_hash).to eq '0000000000000000000000000000000000000000000000000000000000000000'
      me.follow!(remote_alice)
      expect(remote_alice.local_followers_hash).to eq Digest::SHA256.hexdigest(ActivityPub::TagManager.instance.uri_for(me))
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
