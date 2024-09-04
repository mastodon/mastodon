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

    it 'changes the import\'s state as appropriate' do
      expect { subject.perform(import.id) }.to change { import.reload.state.to_sym }.from(:scheduled).to(:in_progress)
    end

    it 'calls BulkImportService' do
      subject.perform(import.id)
      expect(service_double).to have_received(:call).with(import)
    end
  end
end
