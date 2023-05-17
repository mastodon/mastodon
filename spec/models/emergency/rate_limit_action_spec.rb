# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emergency::RateLimitAction do
  describe 'get_rate_limits_for' do
    let(:rule) { Fabricate('Emergency::Rule') }
    let(:account) { Fabricate(:user).account }
    let(:new_users_only) { false }

    before do
      rule.rate_limit_actions.create!(new_users_only: new_users_only)
    end

    context 'when no rule is enabled' do
      it 'returns an empty array' do
        expect(described_class.get_rate_limits_for(:statuses, account, Time.now.utc.to_i)).to eq []
      end
    end

    context 'when a rule is enabled' do
      before do
        rule.trigger!(Time.now.utc)
      end

      context 'when the limit applies to all accounts' do
        it 'returns a rate limit' do
          expect(described_class.get_rate_limits_for(:statuses, account, Time.now.utc.to_i).size).to eq 1
        end
      end

      context 'when the limit applies to new users only' do
        let(:new_users_only) { true }

        context 'when the user is new' do
          it 'returns a rate limit' do
            expect(described_class.get_rate_limits_for(:statuses, account, Time.now.utc.to_i).size).to eq 1
          end
        end

        context 'when the user is old' do
          let(:account) { Fabricate(:user, confirmed_at: 1.month.ago).account }

          it 'returns an empty array' do
            expect(described_class.get_rate_limits_for(:statuses, account, Time.now.utc.to_i)).to eq []
          end
        end
      end
    end
  end
end
