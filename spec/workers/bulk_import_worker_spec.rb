# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkImportWorker do
  subject { described_class.new }

  let(:import) { Fabricate(:bulk_import, state: :scheduled) }

  describe '#perform' do
    let(:service_double) { instance_double(BulkImportService, call: nil) }

    before do
      allow(BulkImportService).to receive(:new).and_return(service_double)
    end

    it 'calls the service and changes the import state' do
      expect { subject.perform(import.id) }
        .to change { import.reload.state.to_sym }.from(:scheduled).to(:in_progress)
      expect(service_double)
        .to have_received(:call).with(import)
    end
  end
end
