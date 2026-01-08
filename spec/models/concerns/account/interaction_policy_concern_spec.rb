# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::InteractionPolicyConcern do
  describe '#feature_policy_as_keys' do
    context 'when account is local' do
      context 'when account is discoverable' do
        let(:account) { Fabricate(:account) }

        it 'returns public for automtatic and nothing for manual' do
          expect(account.feature_policy_as_keys(:automatic)).to eq [:public]
          expect(account.feature_policy_as_keys(:manual)).to eq []
        end
      end

      context 'when account is not discoverable' do
        let(:account) { Fabricate(:account, discoverable: false) }

        it 'returns empty arrays for both inputs' do
          expect(account.feature_policy_as_keys(:automatic)).to eq []
          expect(account.feature_policy_as_keys(:manual)).to eq []
        end
      end
    end

    context 'when account is remote' do
      let(:account) { Fabricate(:account, domain: 'example.com', feature_approval_policy: (0b0101 << 16) | 0b0010) }

      it 'returns the expected values' do
        expect(account.feature_policy_as_keys(:automatic)).to eq ['unsupported_policy', 'followers']
        expect(account.feature_policy_as_keys(:manual)).to eq ['public']
      end
    end
  end

  describe '#feature_policy_for_account' do
    context 'when account is remote' do
      let(:account) { Fabricate(:account, domain: 'example.com', feature_approval_policy:) }
      let(:feature_approval_policy) { (0b0101 << 16) | 0b0010 }
      let(:other_account) { Fabricate(:account) }

      context 'when no policy is available' do
        let(:feature_approval_policy) { 0 }

        context 'when both accounts are the same' do
          it 'returns :automatic' do
            expect(account.feature_policy_for_account(account)).to eq :automatic
          end
        end

        context 'with two different accounts' do
          it 'returns :missing' do
            expect(account.feature_policy_for_account(other_account)).to eq :missing
          end
        end
      end

      context 'when the other account is not following the account' do
        it 'returns :manual because of the public entry in the manual policy' do
          expect(account.feature_policy_for_account(other_account)).to eq :manual
        end
      end

      context 'when the other account is following the account' do
        before do
          other_account.follow!(account)
        end

        it 'returns :automatic because of the followers entry in the automatic policy' do
          expect(account.feature_policy_for_account(other_account)).to eq :automatic
        end
      end

      context 'when the account falls into the unknown bucket' do
        let(:feature_approval_policy) { (0b0001 << 16) | 0b0100 }

        it 'returns :automatic because of the followers entry in the automatic policy' do
          expect(account.feature_policy_for_account(other_account)).to eq :unknown
        end
      end
    end
  end
end
