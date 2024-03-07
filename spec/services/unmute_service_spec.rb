# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnmuteService do
  describe '#call' do
    let!(:account) { Fabricate(:account) }
    let!(:target_account) { Fabricate(:account) }

    context 'when account is muting target account' do
      before { Fabricate :mute, account: account, target_account: target_account }

      context 'when account follows target_account' do
        before { Fabricate :follow, account: account, target_account: target_account }

        it 'removes the account mute and sets up a merge' do
          expect { subject.call(account, target_account) }
            .to remove_account_mute
          expect(MergeWorker).to have_enqueued_sidekiq_job(target_account.id, account.id)
        end
      end

      context 'when account does not follow target_account' do
        it 'removes the account mute and does not create a merge' do
          expect { subject.call(account, target_account) }
            .to remove_account_mute
          expect(MergeWorker).to_not have_enqueued_sidekiq_job
        end
      end

      def remove_account_mute
        change { account.reload.muting?(target_account) }
          .from(true)
          .to(false)
      end
    end

    context 'when account is not muting target account' do
      it 'does nothing and returns' do
        expect { subject.call(account, target_account) }
          .to_not(change { account.reload.muting?(target_account) })
        expect(MergeWorker).to_not have_enqueued_sidekiq_job
      end
    end
  end
end
