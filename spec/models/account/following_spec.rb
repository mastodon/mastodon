# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Following do
  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'Associations' do
    subject { Fabricate.build :account }

    it { is_expected.to have_many(:follow_requests) }

    it { is_expected.to have_many(:active_relationships).class_name(Follow).dependent(:destroy).inverse_of(:account).with_foreign_key(:account_id) }
    it { is_expected.to have_many(:passive_relationships).class_name(Follow).dependent(:destroy).inverse_of(:target_account).with_foreign_key(:target_account_id) }

    it { is_expected.to have_many(:following).through(:active_relationships).source(:target_account) }
    it { is_expected.to have_many(:followers).through(:passive_relationships).source(:account) }
  end

  describe '#follow!' do
    it 'creates and returns Follow' do
      expect { expect(account.follow!(target_account)).to be_a(Follow) }
        .to change { account.following.count }.by(1)
    end
  end

  describe '#request_follow!' do
    it 'creates and returns Follow' do
      expect { expect(account.request_follow!(target_account)).to be_a(FollowRequest) }
        .to change { account.follow_requests.count }.by(1)
        .and not_change(account.following, :count)
    end
  end

  describe '#unfollow!' do
    subject { account.unfollow!(target_account) }

    context 'when following target_account' do
      before { account.active_relationships.create(target_account: target_account) }

      it 'returns destroyed Follow' do
        expect(subject)
          .to be_a(Follow)
          .and be_destroyed
      end
    end

    context 'when not following target_account' do
      it { is_expected.to be_nil }
    end
  end

  describe '#following?' do
    subject { account.following?(target_account) }

    context 'when following target_account' do
      before { account.active_relationships.create(target_account: target_account) }

      it 'returns true' do
        expect { expect(subject).to be(true) }
          .to execute_queries
      end

      context 'when relations are preloaded' do
        before {           account.preload_relations!([target_account.id]) }

        it 'does not query the database to get the result' do
          expect { expect(subject).to be(true) }
            .to_not execute_queries
        end
      end
    end

    context 'when not following target_account' do
      it { is_expected.to be(false) }
    end
  end

  describe '#followed_by?' do
    subject { account.followed_by?(target_account) }

    context 'when followed by target_account' do
      before { account.passive_relationships.create(account: target_account) }

      it { is_expected.to be(true) }
    end

    context 'when not followed by target_account' do
      it { is_expected.to be(false) }
    end
  end
end
