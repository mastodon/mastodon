# frozen_string_literal: true

require 'rails_helper'

describe Pubsubhubbub::UnsubscribeService do
  describe '#call' do
    subject { described_class.new }

    context 'with a nil account' do
      it 'returns an invalid topic status' do
        result = subject.call(nil, 'callback.host')

        expect(result).to eq invalid_topic_status
      end
    end

    context 'with a valid account' do
      let(:account) { Fabricate(:account) }

      it 'returns a valid topic status and does not run confirm when no subscription' do
        allow(Pubsubhubbub::ConfirmationWorker).to receive(:perform_async).and_return(nil)
        result = subject.call(account, 'callback.host')

        expect(result).to eq valid_topic_status
        expect(Pubsubhubbub::ConfirmationWorker).not_to have_received(:perform_async)
      end

      it 'returns a valid topic status and does run confirm when there is a subscription' do
        subscription = Fabricate(:subscription, account: account, callback_url: 'callback.host')
        allow(Pubsubhubbub::ConfirmationWorker).to receive(:perform_async).and_return(nil)
        result = subject.call(account, 'callback.host')

        expect(result).to eq valid_topic_status
        expect(Pubsubhubbub::ConfirmationWorker).to have_received(:perform_async).with(subscription.id, 'unsubscribe')
      end
    end

    def invalid_topic_status
      ['Invalid topic URL', 422]
    end

    def valid_topic_status
      ['', 202]
    end
  end
end
