# frozen_string_literal: true

require 'rails_helper'

describe PollExpirationNotifyWorker do
  let(:worker) { described_class.new }
  let(:account) { Fabricate(:account, domain: remote? ? 'example.com' : nil) }
  let(:status) { Fabricate(:status, account: account) }
  let(:poll) { Fabricate(:poll, status: status, account: account) }
  let(:remote?) { false }
  let(:poll_vote) { Fabricate(:poll_vote, poll: poll) }

  describe '#perform' do
    around do |example|
      Sidekiq::Testing.fake! do
        example.run
      end
    end

    it 'runs without error for missing record' do
      expect { worker.perform(nil) }.to_not raise_error
    end

    context 'when poll is not expired' do
      it 'requeues job' do
        worker.perform(poll.id)
        expect(described_class.sidekiq_options_hash['lock']).to be :until_executing
        expect(described_class).to have_enqueued_sidekiq_job(poll.id).at(poll.expires_at + 5.minutes)
      end
    end

    context 'when poll is expired' do
      before do
        poll_vote

        travel_to poll.expires_at + 5.minutes

        worker.perform(poll.id)
      end

      context 'when poll is local' do
        it 'notifies voters' do
          expect(ActivityPub::DistributePollUpdateWorker).to have_enqueued_sidekiq_job(poll.status.id)
        end

        it 'notifies owner' do
          expect(LocalNotificationWorker).to have_enqueued_sidekiq_job(poll.account.id, poll.id, 'Poll', 'poll')
        end

        it 'notifies local voters' do
          expect(LocalNotificationWorker).to have_enqueued_sidekiq_job(poll_vote.account.id, poll.id, 'Poll', 'poll')
        end
      end

      context 'when poll is remote' do
        let(:remote?) { true }

        it 'does not notify remote voters' do
          expect(ActivityPub::DistributePollUpdateWorker).to_not have_enqueued_sidekiq_job(poll.status.id)
        end

        it 'does not notify owner' do
          expect(LocalNotificationWorker).to_not have_enqueued_sidekiq_job(poll.account.id, poll.id, 'Poll', 'poll')
        end

        it 'notifies local voters' do
          expect(LocalNotificationWorker).to have_enqueued_sidekiq_job(poll_vote.account.id, poll.id, 'Poll', 'poll')
        end
      end
    end
  end
end
