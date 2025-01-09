# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FollowersSynchronizationWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ActivityPub::SynchronizeFollowersService, call: true) }

  describe '#perform' do
    before { stub_service }

    let(:account) { Fabricate(:account, domain: 'host.example') }
    let(:url) { 'https://sync.url' }

    it 'sends the status to the service' do
      worker.perform(account.id, url)

      expect(service).to have_received(:call).with(account, url)
    end

    it 'returns nil for non-existent record' do
      result = worker.perform(123_123_123, url)

      expect(result).to be(true)
    end
  end

  def stub_service
    allow(ActivityPub::SynchronizeFollowersService)
      .to receive(:new)
      .and_return(service)
  end
end
