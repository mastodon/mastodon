# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FamiliarFollowersPresenter do
  describe '#accounts' do
    subject { described_class.new(requested_accounts, account.id) }

    let(:account) { Fabricate(:account) }
    let(:familiar_follower) { Fabricate(:account) }
    let(:requested_accounts) { Fabricate.times(2, :account) }

    before do
      familiar_follower.follow!(requested_accounts.first)
      account.follow!(familiar_follower)
    end

    it 'returns a result for each requested account' do
      expect(subject.accounts.map(&:id)).to eq requested_accounts.map(&:id)
    end

    it 'returns followers you follow' do
      result = subject.accounts.first

      expect(result)
        .to be_present
        .and have_attributes(
          id: requested_accounts.first.id,
          accounts: contain_exactly(familiar_follower)
        )
    end

    context 'when requested account hides followers' do
      before do
        requested_accounts.first.update(hide_collections: true)
      end

      it 'does not return followers you follow' do
        result = subject.accounts.first

        expect(result)
          .to be_present
          .and have_attributes(
            id: requested_accounts.first.id,
            accounts: be_empty
          )
      end
    end

    context 'when familiar follower hides follows' do
      before do
        familiar_follower.update(hide_collections: true)
      end

      it 'does not return followers you follow' do
        result = subject.accounts.first

        expect(result)
          .to be_present
          .and have_attributes(
            id: requested_accounts.first.id,
            accounts: be_empty
          )
      end
    end
  end
end
