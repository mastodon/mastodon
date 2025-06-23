# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Mappings do
  let(:account)            { Fabricate(:account) }
  let(:account_id)         { account.id }
  let(:account_ids)        { [account_id] }
  let(:target_account)     { Fabricate(:account) }
  let(:target_account_id)  { target_account.id }
  let(:target_account_ids) { [target_account_id] }

  describe '.following_map' do
    subject { Account.following_map(target_account_ids, account_id) }

    context 'when Account has a Follow' do
      before { Fabricate(:follow, account: account, target_account: target_account) }

      it { is_expected.to eq(target_account_id => { reblogs: true, notify: false, languages: nil }) }
    end

    context 'when Account is without Follow' do
      it { is_expected.to eq({}) }
    end

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.followed_by_map' do
    subject { Account.followed_by_map(target_account_ids, account_id) }

    context 'when Account has a Follow' do
      before { Fabricate(:follow, account: target_account, target_account: account) }

      it { is_expected.to eq(target_account_id => true) }
    end

    context 'when Account is without Follow' do
      it { is_expected.to eq({}) }
    end

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.blocking_map' do
    subject { Account.blocking_map(target_account_ids, account_id) }

    context 'when Account has a Block' do
      before { Fabricate(:block, account: account, target_account: target_account) }

      it { is_expected.to eq(target_account_id => true) }
    end

    context 'when Account is without Block' do
      it { is_expected.to eq({}) }
    end

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.blocked_by_map' do
    subject { Account.blocked_by_map(target_account_ids, account_id) }

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.muting_map' do
    subject { Account.muting_map(target_account_ids, account_id) }

    context 'when Account has a Mute' do
      before { Fabricate(:mute, target_account: target_account, account: account, hide_notifications: hide) }

      context 'when Mute#hide_notifications?' do
        let(:hide) { true }

        it { is_expected.to eq(target_account_id => { notifications: true }) }
      end

      context 'when not Mute#hide_notifications?' do
        let(:hide) { false }

        it { is_expected.to eq(target_account_id => { notifications: false }) }
      end
    end

    context 'when Account without Mute' do
      it { is_expected.to eq({}) }
    end

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.requested_map' do
    subject { Account.requested_map(target_account_ids, account_id) }

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.requested_by_map' do
    subject { Account.requested_by_map(target_account_ids, account_id) }

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.endorsed_map' do
    subject { Account.endorsed_map(target_account_ids, account_id) }

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe '.account_note_map' do
    subject { Account.account_note_map(target_account_ids, account_id) }

    context 'when given empty values' do
      let(:target_account_ids) { [] }
      let(:account_id) { 1 }

      it { is_expected.to be_a(Hash) }
    end
  end
end
