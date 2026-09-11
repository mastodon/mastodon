# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteAccountRefreshWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    before { stub_service }

    let(:account) { Fabricate(:account, domain: 'host.example') }

    context 'with a working service' do
      let(:service) { instance_double(ActivityPub::FetchRemoteAccountService, call: true) }

      it 'sends the status to the service' do
        worker.perform(account.id)

        expect(service).to have_received(:call).with(account.uri)
      end

      it 'returns nil for non-existent record' do
        result = worker.perform(123_123_123)

        expect(result).to be_nil
      end

      it 'returns nil for a local record' do
        account = Fabricate :account, domain: nil
        result = worker.perform(account.id)
        expect(result).to be_nil
      end
    end

    context 'with a failing service' do
      let(:service) { instance_double(ActivityPub::FetchRemoteAccountService) }
      let(:response) { instance_double(HTTP::Response, code: 500) }

      before { allow(service).to receive(:call).and_raise(Mastodon::UnexpectedResponseError, response) }

      it 'raises error when service fails' do
        expect { worker.perform(account.id) }
          .to raise_error(Mastodon::UnexpectedResponseError)
      end
    end

    def stub_service
      allow(ActivityPub::FetchRemoteAccountService)
        .to receive(:new)
        .and_return(service)
    end
  end
end
