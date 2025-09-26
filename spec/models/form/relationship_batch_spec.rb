# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::RelationshipBatch do
  describe '#persisted?' do
    it { is_expected.to be_persisted }
  end

  describe '#save' do
    subject { described_class.new(action:, account_ids:, current_account:).save }

    let(:account_ids) { [account.id] }
    let(:account) { Fabricate :account }
    let(:current_account) { Fabricate :account }

    context 'when action is follow' do
      let(:action) { 'follow' }
      let(:account_ids) { [account.id] }

      it 'adds a follow for the accounts' do
        expect { subject }
          .to change(Follow, :count).by(1)
          .and change { current_account.reload.active_relationships.exists?(target_account: account) }.from(false).to(true)
      end

      context 'when account cannot be followed' do
        let(:account) { Fabricate :account, domain: 'test.example' }

        it 'does not save follows and re-raises error' do
          expect { subject }
            .to raise_error(Mastodon::NotPermittedError)
            .and not_change(Follow, :count)
        end
      end
    end

    context 'when action is unfollow' do
      let(:action) { 'unfollow' }

      before { Fabricate :follow, account: current_account, target_account: account }

      it 'removes a follow for the accounts' do
        expect { subject }
          .to change(Follow, :count).by(-1)
          .and change { current_account.reload.active_relationships.exists?(target_account: account) }.from(true).to(false)
      end
    end

    context 'when action is remove_from_followers' do
      let(:action) { 'remove_from_followers' }

      before { Fabricate :follow, account: account, target_account: current_account }

      it 'removes followers from the accounts' do
        expect { subject }
          .to change(Follow, :count).by(-1)
          .and change { current_account.reload.passive_relationships.exists?(account: account) }.from(true).to(false)
      end
    end

    context 'when action is remove_domains_from_followers' do
      let(:action) { 'remove_domains_from_followers' }

      let(:account) { Fabricate :account, domain: 'host.example' }
      let(:account_other) { Fabricate :account, domain: 'host.example' }

      before do
        Fabricate :follow, account: account, target_account: current_account
        Fabricate :follow, account: account_other, target_account: current_account
      end

      it 'removes all followers from domains of the accounts' do
        expect { subject }
          .to change(Follow, :count).by(-2)
          .and change { current_account.reload.passive_relationships.exists?(account: account) }.from(true).to(false)
          .and change { current_account.reload.passive_relationships.exists?(account: account_other) }.from(true).to(false)
      end
    end

    context 'when action is unknown' do
      let(:action) { 'unknown' }

      it { is_expected.to be_nil }
    end
  end
end
