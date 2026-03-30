# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessFeaturedItemWorker do
  subject { described_class.new }

  let(:collection) { Fabricate(:remote_collection) }
  let(:object) { 'https://example.com/featured_items/1' }
  let(:stubbed_service) do
    instance_double(ActivityPub::ProcessFeaturedItemService, call: true)
  end

  before do
    allow(ActivityPub::ProcessFeaturedItemService).to receive(:new).and_return(stubbed_service)
  end

  describe 'perform' do
    it 'calls the service to process the item' do
      subject.perform(collection.id, object)

      expect(stubbed_service).to have_received(:call).with(collection, object, position: nil, request_id: nil)
    end
  end
end
