# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FamiliarFollowersPresenter do
  describe '#accounts' do
    let(:account) { Fabricate(:account) }
    let(:familiar_follower) { Fabricate(:account) }
    let(:requested_accounts) { Fabricate.times(2, :account) }

    subject { described_class.new(requested_accounts, account.id) }

    before do
      familiar_follower.follow!(requested_accounts.first)
      account.follow!(familiar_follower)
    end

    it 'returns a result for each requested account' do
      expect(subject.accounts.map(&:id)).to eq requested_accounts.map(&:id)
    end

    it 'returns followers you follow' do
      result = subject.accounts.first

      expect(result).to_not be_nil
      expect(result.id).to eq requested_accounts.first.id
      expect(result.accounts).to match_array([familiar_follower])
    end

    context 'when requested account hides followers' do
      before do
        requested_accounts.first.update(hide_collections: true)
      end

      it 'does not return followers you follow' do
        result = subject.accounts.first

        expect(result).to_not be_nil
        expect(result.id).to eq requested_accounts.first.id
        expect(result.accounts).to be_empty
      end
    end

    context 'when familiar follower hides follows' do
      before do
        familiar_follower.update(hide_collections: true)
      end

      it 'does not return followers you follow' do
        result = subject.accounts.first

        expect(result).to_not be_nil
        expect(result.id).to eq requested_accounts.first.id
        expect(result.accounts).to be_empty
      end
    end
  end
end
