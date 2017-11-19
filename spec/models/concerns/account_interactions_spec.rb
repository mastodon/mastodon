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
        is_expected.to eq(target_account_id => true)
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
end
