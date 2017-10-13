# frozen_string_literal: true

require 'rails_helper'

describe Pubsubhubbub::UnsubscribeService do
  describe '#call' do
    around { |example| Sidekiq::Testing.fake! &example }
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
        result = subject.call(account, 'callback.host')

        expect(result).to eq valid_topic_status
        expect(Pubsubhubbub::ConfirmationWorker).not_to have_enqueued_sidekiq_job
      end

      it 'returns a valid topic status and does run confirm when there is a subscription' do
        subscription = Fabricate(:subscription, account: account, callback_url: 'callback.host')
        result = subject.call(account, 'callback.host')

        expect(result).to eq valid_topic_status
        expect(Pubsubhubbub::ConfirmationWorker).to have_enqueued_sidekiq_job subscription.id, 'unsubscribe'
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
