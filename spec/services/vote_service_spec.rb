# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VoteService do
  describe '#call' do
    subject { described_class.new.call(voter, poll, [0]) }

    context 'with a poll and poll options' do
      let(:poll) { Fabricate(:poll, account: account, options: %w(Fun UnFun)) }
      let(:fun_vote) { Fabricate(:poll_vote, poll: poll) }
      let(:not_fun_vote) { Fabricate(:poll_vote, poll: poll) }
      let(:voter) { Fabricate(:account, domain: nil) }

      context 'when the poll was created by a local account' do
        let(:account) { Fabricate(:account, domain: nil) }

        it 'stores the votes and distributes the poll' do
          expect { subject }
            .to change(PollVote, :count).by(1)

          expect(ActivityPub::DistributePollUpdateWorker)
            .to have_enqueued_sidekiq_job(poll.status.id)
        end
      end

      context 'when the poll was created by a remote account' do
        let(:account) { Fabricate(:account, domain: 'host.example') }

        it 'stores the votes and processes delivery' do
          expect { subject }
            .to change(PollVote, :count).by(1)

          expect(ActivityPub::DeliveryWorker)
            .to have_enqueued_sidekiq_job(anything, voter.id, poll.account.inbox_url)
        end
      end
    end
  end
end
