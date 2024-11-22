# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemovalWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(RemoveStatusService, call: true) }

  describe '#perform' do
    before do
      allow(RemoveStatusService).to receive(:new).and_return(service)
    end

    let(:status) { Fabricate(:status) }

    it 'sends the status to the service' do
      worker.perform(status.id)

      expect(service).to have_received(:call).with(status)
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123)

      expect(result).to be(true)
    end
  end
end
