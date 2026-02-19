# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::FollowRecommendationsScheduler do
  let!(:target_accounts) do
    Fabricate.times(3, :account) do
      statuses(count: 6)
    end
  end
  let!(:follower_accounts) do
    Fabricate.times(5, :account) do
      statuses(count: 6)
    end
  end

  describe '#perform' do
    subject(:scheduled_run) { described_class.new.perform }

    context 'when there are accounts to recommend' do
      before do
        # Follow the target accounts by follow accounts to make them recommendable
        follower_accounts.each do |follower_account|
          target_accounts.each do |target_account|
            Fabricate(:follow, account: follower_account, target_account: target_account)
          end
        end
      end

      it 'creates recommendations' do
        expect { scheduled_run }.to change(FollowRecommendation, :count).from(0).to(target_accounts.size)
      end
    end

    context 'when there are no accounts to recommend' do
      it 'does not create follow recommendations' do
        expect { scheduled_run }.to_not change(FollowRecommendation, :count)
      end
    end
  end
end
