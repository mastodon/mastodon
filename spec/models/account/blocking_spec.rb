# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Blocking do
  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'Associations' do
    subject { Fabricate.build :account }

    it { is_expected.to have_many(:block_relationships).class_name(Block).dependent(:destroy).inverse_of(:account).with_foreign_key(:account_id) }
    it { is_expected.to have_many(:blocked_by_relationships).class_name(Block).dependent(:destroy).inverse_of(:target_account).with_foreign_key(:target_account_id) }

    it { is_expected.to have_many(:blocking).through(:block_relationships).source(:target_account) }
    it { is_expected.to have_many(:blocked_by).through(:blocked_by_relationships).source(:account) }
  end

  describe '#block' do
    it 'creates and returns Block' do
      expect { expect(account.block!(target_account)).to be_a(Block) }
        .to change { account.block_relationships.count }.by(1)
    end
  end

  describe '#unblock!' do
    subject { account.unblock!(target_account) }

    context 'when blocking target_account' do
      before { account.block_relationships.create(target_account: target_account) }

      it 'returns destroyed Block' do
        expect(subject)
          .to be_a(Block)
          .and be_destroyed
      end
    end

    context 'when not blocking target_account' do
      it { is_expected.to be_nil }
    end
  end

  describe '#blocking?' do
    subject { account.blocking?(target_account) }

    context 'when blocking target_account' do
      before { account.block_relationships.create(target_account: target_account) }

      it 'returns true' do
        result = nil
        expect { result = subject }.to execute_queries

        expect(result).to be true
      end

      context 'when relations are preloaded' do
        it 'does not query the database to get the result' do
          account.preload_relations!([target_account.id])

          result = nil
          expect { result = subject }.to_not execute_queries

          expect(result).to be true
        end
      end
    end

    context 'when not blocking target_account' do
      it { is_expected.to be(false) }
    end
  end

  describe '#blocked_by?' do
    subject { account.blocked_by?(target_account) }

    context 'when blocked by target_account' do
      before { target_account.block_relationships.create(target_account: account) }

      it 'returns true and queries' do
        expect { expect(subject).to be(true) }
          .to execute_queries
      end

      context 'when relations are preloaded' do
        before { account.preload_relations!([target_account.id]) }

        it 'returns true and does not query' do
          expect { expect(subject).to be(true) }
            .to_not execute_queries
        end
      end
    end

    context 'when not blocked by target_account' do
      it { is_expected.to be(false) }
    end
  end
end
