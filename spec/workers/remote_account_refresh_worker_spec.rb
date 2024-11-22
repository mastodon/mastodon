# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteAccountRefreshWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ActivityPub::FetchRemoteAccountService, call: true) }

  describe '#perform' do
    before { stub_service }

    let(:account) { Fabricate(:account, domain: 'host.example') }

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
      result = worker.perform(account)
      expect(result).to be_nil
    end

    def stub_service
      allow(ActivityPub::FetchRemoteAccountService)
        .to receive(:new)
        .and_return(service)
    end
  end
end
