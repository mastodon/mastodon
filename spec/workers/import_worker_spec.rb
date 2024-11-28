# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(ImportService, call: true) }

  describe '#perform' do
    before do
      allow(ImportService).to receive(:new).and_return(service)
    end

    let(:import) { Fabricate(:import) }

    it 'sends the import to the service' do
      worker.perform(import.id)

      expect(service).to have_received(:call).with(import)
      expect { import.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
