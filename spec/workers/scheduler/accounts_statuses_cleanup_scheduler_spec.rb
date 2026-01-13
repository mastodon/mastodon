# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::AccountsStatusesCleanupScheduler do
  subject { described_class.new }

  let!(:account_alice) { Fabricate(:account, domain: nil, username: 'alice') }
  let!(:account_bob) { Fabricate(:account, domain: nil, username: 'bob') }
  let!(:account_chris) { Fabricate(:account, domain: nil, username: 'chris') }
  let!(:account_dave) { Fabricate(:account, domain: nil, username: 'dave') }
  let!(:account_erin) { Fabricate(:account, domain: nil, username: 'erin') }
  let!(:remote) { Fabricate(:account) }

  let(:queue_size)       { 0 }
  let(:queue_latency)    { 0 }
  let(:process_set_stub) do
    [
      {
        'concurrency' => 2,
        'queues' => %w(push default),
      },
    ]
  end

  before do
    queue_stub = instance_double(Sidekiq::Queue, size: queue_size, latency: queue_latency)
    allow(Sidekiq::Queue).to receive(:new).and_return(queue_stub)
    allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set_stub)

    sidekiq_stats_stub = instance_double(Sidekiq::Stats)
    allow(Sidekiq::Stats).to receive(:new).and_return(sidekiq_stats_stub)
  end

  describe '#under_load?' do
    context 'when nothing is queued' do
      it 'returns false' do
        expect(subject.under_load?).to be false
      end
    end

    context 'when numerous jobs are queued' do
      let(:queue_size)    { 5 }
      let(:queue_latency) { 120 }

      it 'returns true' do
        expect(subject.under_load?).to be true
      end
    end
  end

  describe '#compute_budget' do
    context 'with a single thread' do
      let(:process_set_stub) { [{ 'concurrency' => 1, 'queues' => %w(push default) }] }

      it 'returns a low value' do
        expect(subject.compute_budget).to be < 10
      end
    end

    context 'with a lot of threads' do
      let(:process_set_stub) do
        [
          { 'concurrency' => 2, 'queues' => %w(push default) },
          { 'concurrency' => 2, 'queues' => ['push'] },
          { 'concurrency' => 2, 'queues' => ['push'] },
          { 'concurrency' => 2, 'queues' => ['push'] },
        ]
      end

      it 'returns a larger value' do
        expect(subject.compute_budget).to be > 10
      end
    end
  end

  describe '#perform' do
    around do |example|
      Timeout.timeout(30) do
        example.run
      end
    end

    before do
      # Policies for the accounts
      Fabricate(:account_statuses_cleanup_policy, account: account_alice)
      Fabricate(:account_statuses_cleanup_policy, account: account_chris)
      Fabricate(:account_statuses_cleanup_policy, account: account_dave, enabled: false)
      Fabricate(:account_statuses_cleanup_policy, account: account_erin)

      # Create a bunch of old statuses
      4.times do
        Fabricate(:status, account: account_alice, created_at: 3.years.ago)
        Fabricate(:status, account: account_bob, created_at: 3.years.ago)
        Fabricate(:status, account: account_chris, created_at: 3.years.ago)
        Fabricate(:status, account: account_dave, created_at: 3.years.ago)
        Fabricate(:status, account: account_erin, created_at: 3.years.ago)
        Fabricate(:status, account: remote, created_at: 3.years.ago)
      end

      # Create a bunch of newer statuses
      Fabricate(:status, account: account_alice, created_at: 3.minutes.ago)
      Fabricate(:status, account: account_bob, created_at: 3.minutes.ago)
      Fabricate(:status, account: account_chris, created_at: 3.minutes.ago)
      Fabricate(:status, account: account_dave, created_at: 3.minutes.ago)
      Fabricate(:status, account: remote, created_at: 3.minutes.ago)
    end

    context 'when the budget is lower than the number of toots to delete' do
      it 'deletes the appropriate statuses' do
        expect(Status.count).to be > subject.compute_budget # Data check

        expect { subject.perform }
          .to change(Status, :count).by(-subject.compute_budget) # Cleanable statuses
          .and not_change { account_bob.statuses.count } # No cleanup policy for account
          .and(not_change { account_dave.statuses.count }) # Disabled cleanup policy
      end

      it 'eventually deletes every deletable toot given enough runs' do
        stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 4

        expect { 3.times { subject.perform } }.to change(Status, :count).by(-cleanable_statuses_count)
      end

      it 'correctly round-trips between users across several runs' do
        stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 3
        stub_const 'Scheduler::AccountsStatusesCleanupScheduler::PER_ACCOUNT_BUDGET', 2

        expect { 3.times { subject.perform } }
          .to change(Status, :count).by(-3 * 3)
          .and change { account_alice.statuses.count }
          .and change { account_chris.statuses.count }
          .and(change { account_erin.statuses.count })
      end

      context 'when given a big budget' do
        let(:process_set_stub) { [{ 'concurrency' => 400, 'queues' => %w(push default) }] }

        before do
          stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 400
        end

        it 'correctly handles looping in a single run' do
          expect(subject.compute_budget).to eq(400)
          expect { subject.perform }.to change(Status, :count).by(-cleanable_statuses_count)
        end
      end

      context 'when there is no work to be done' do
        let(:process_set_stub) { [{ 'concurrency' => 400, 'queues' => %w(push default) }] }

        before do
          stub_const 'Scheduler::AccountsStatusesCleanupScheduler::MAX_BUDGET', 400
          subject.perform
        end

        it 'does not get stuck' do
          expect(subject.compute_budget).to eq(400)
          expect { subject.perform }.to_not change(Status, :count)
        end
      end

      def cleanable_statuses_count
        Status
          .where(account_id: [account_alice, account_chris, account_erin]) # Accounts with enabled policies
          .where(created_at: ...2.weeks.ago) # Policy defaults is 2.weeks
          .count
      end
    end
  end
end
