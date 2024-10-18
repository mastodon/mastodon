# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollPolicy do
  subject { described_class }

  let(:account) { Fabricate(:account) }
  let(:poll) { Fabricate :poll }

  permissions :vote? do
    context 'when account cannot view status' do
      before { poll.status.update(visibility: :private) }

      it { is_expected.to_not permit(account, poll) }
    end

    context 'when account can view status' do
      context 'when accounts do not block each other' do
        it { is_expected.to permit(account, poll) }
      end

      context 'when view blocks poll creator' do
        before { Fabricate :block, account: account, target_account: poll.account }

        it { is_expected.to_not permit(account, poll) }
      end

      context 'when poll creator blocks viewer' do
        before { Fabricate :block, account: poll.account, target_account: account }

        it { is_expected.to_not permit(account, poll) }
      end
    end
  end
end
