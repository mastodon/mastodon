# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::VerifyFeaturedItemWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ActivityPub::VerifyFeaturedItemService, call: true) }

  describe '#perform' do
    let(:collection_item) { Fabricate(:unverified_remote_collection_item) }

    before { stub_service }

    it 'sends the status to the service' do
      worker.perform(collection_item.id, 'https://example.com/authorizations/1')

      expect(service).to have_received(:call).with(collection_item, 'https://example.com/authorizations/1', request_id: nil)
    end

    it 'returns nil for non-existent record' do
      result = worker.perform(123_123_123, 'https://example.com/authorizations/1')

      expect(result).to be_nil
    end
  end

  def stub_service
    allow(ActivityPub::VerifyFeaturedItemService)
      .to receive(:new)
      .and_return(service)
  end
end
