# frozen_string_literal: true

require 'rails_helper'

describe Pubsubhubbub::SubscribeService do
  describe '#call' do
    subject { described_class.new }
    let(:user_account) { Fabricate(:account) }

    context 'with a nil account' do
      it 'returns the invalid topic status results' do
        result = service_call(account: nil)

        expect(result).to eq invalid_topic_status
      end
    end

    context 'with an invalid callback url' do
      it 'returns invalid callback status when callback is blank' do
        result = service_call(callback: '')

        expect(result).to eq invalid_callback_status
      end
      it 'returns invalid callback status when callback is not a URI' do
        result = service_call(callback: 'invalid-hostname')

        expect(result).to eq invalid_callback_status
      end
    end

    context 'with a blocked domain in the callback' do
      it 'returns callback not allowed' do
        Fabricate(:domain_block, domain: 'test.host', severity: :suspend)
        result = service_call(callback: 'https://test.host/api')

        expect(result).to eq not_allowed_callback_status
      end
    end

    context 'with a valid account and callback' do
      it 'returns success status and confirms subscription' do
        allow(Pubsubhubbub::ConfirmationWorker).to receive(:perform_async).and_return(nil)
        subscription = Fabricate(:subscription, account: user_account)

        result = service_call(callback: subscription.callback_url)
        expect(result).to eq success_status
        expect(Pubsubhubbub::ConfirmationWorker).to have_received(:perform_async).with(subscription.id, 'subscribe', 'asdf', 3600)
      end
    end
  end

  def service_call(account: user_account, callback: 'https://callback.host', secret: 'asdf', lease_seconds: 3600)
    subject.call(account, callback, secret, lease_seconds)
  end

  def invalid_topic_status
    ['Invalid topic URL', 422]
  end

  def invalid_callback_status
    ['Invalid callback URL', 422]
  end

  def not_allowed_callback_status
    ['Callback URL not allowed', 403]
  end

  def success_status
    ['', 202]
  end
end
