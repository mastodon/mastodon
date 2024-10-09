# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::SynchronizeFeaturedTagsCollectionWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ActivityPub::FetchFeaturedTagsCollectionService, call: true) }

  describe '#perform' do
    before do
      allow(ActivityPub::FetchFeaturedTagsCollectionService).to receive(:new).and_return(service)
    end

    let(:account) { Fabricate(:account) }
    let(:url) { 'https://host.example' }

    it 'sends the account and url to the service' do
      worker.perform(account.id, url)

      expect(service).to have_received(:call).with(account, url)
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123, url)

      expect(result).to be(true)
    end
  end
end
