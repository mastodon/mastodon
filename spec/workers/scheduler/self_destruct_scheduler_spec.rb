# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::SelfDestructScheduler do
  let(:worker) { described_class.new }

  describe '#perform' do
    let!(:account) { Fabricate(:account, domain: nil, suspended_at: nil) }

    context 'when not in self destruct mode' do
      before do
        allow(SelfDestructHelper).to receive(:self_destruct?).and_return(false)
      end

      it 'returns without processing' do
        worker.perform

        expect(account.reload.suspended_at).to be_nil
      end
    end

    context 'when in self-destruct mode' do
      before do
        allow(SelfDestructHelper).to receive(:self_destruct?).and_return(true)
      end

      context 'when sidekiq is overwhelmed' do
        before do
          stats = instance_double(Sidekiq::Stats, enqueued: described_class::MAX_ENQUEUED**2)
          allow(Sidekiq::Stats).to receive(:new).and_return(stats)
        end

        it 'returns without processing' do
          worker.perform

          expect(account.reload.suspended_at).to be_nil
        end
      end

      context 'when sidekiq is operational' do
        it 'suspends local non-suspended accounts' do
          worker.perform

          expect(account.reload.suspended_at).to_not be_nil
        end

        it 'suspends local suspended accounts marked for deletion' do
          account.update(suspended_at: 10.days.ago)
          deletion_request = Fabricate(:account_deletion_request, account: account)

          worker.perform

          expect(account.reload.suspended_at).to be > 1.day.ago
          expect { deletion_request.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
