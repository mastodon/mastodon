# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::RowWorker do
  subject { described_class.new }

  let(:row) { Fabricate(:bulk_import_row, bulk_import: import) }

  describe '#perform' do
    before { allow(BulkImportRowService).to receive(:new).and_return(service_double) }

    shared_context 'when service succeeds' do
      let(:service_double) { instance_double(BulkImportRowService, call: true) }
    end

    shared_context 'when service fails' do
      let(:service_double) { instance_double(BulkImportRowService, call: false) }
    end

    shared_context 'when service errors' do
      let(:service_double) { instance_double(BulkImportRowService) }
      before { allow(service_double).to receive(:call).and_raise('dummy error') }
    end

    shared_examples 'clean failure' do
      it 'calls service, increases processed items, preserves imported items, and keeps row' do
        expect { subject.perform(row.id) }
          .to change { import.reload.processed_items }.by(+1)
          .and not_change { import.reload.imported_items }
          .and(not_change { BulkImportRow.exists?(row.id) }.from(true))
        expect(service_double)
          .to have_received(:call).with(row)
      end
    end

    shared_examples 'unclean failure' do
      it 'raises an error, preserves processed items, and keeps row' do
        expect { subject.perform(row.id) }
          .to raise_error(StandardError, 'dummy error')
          .and(not_change { import.reload.processed_items })
          .and(not_change { BulkImportRow.exists?(row.id) }.from(true))
      end
    end

    shared_examples 'clean success' do
      it 'calls service, increases processed items, increases imported items, and deletes row' do
        expect { subject.perform(row.id) }
          .to change { import.reload.processed_items }.by(+1)
          .and change { import.reload.imported_items }.by(+1)
          .and(change { BulkImportRow.exists?(row.id) }.from(true).to(false))
        expect(service_double).to have_received(:call).with(row)
      end
    end

    context 'when there are multiple rows to process' do
      let(:import) { Fabricate(:bulk_import, total_items: 2, processed_items: 0, imported_items: 0, state: :in_progress) }

      context 'with a clean failure' do
        include_context 'when service fails'
        it_behaves_like 'clean failure'

        it 'does not mark the import as finished' do
          expect { subject.perform(row.id) }
            .to_not(change { import.reload.state.to_sym })
        end
      end

      context 'with an unclean failure' do
        include_context 'when service errors'
        it_behaves_like 'unclean failure'

        it 'does not mark the import as finished' do
          expect { subject.perform(row.id) }
            .to raise_error(StandardError)
            .and(not_change { import.reload.state.to_sym })
        end
      end

      context 'with a clean success' do
        include_context 'when service succeeds'
        it_behaves_like 'clean success'

        it 'does not mark the import as finished' do
          expect { subject.perform(row.id) }
            .to_not(change { import.reload.state.to_sym })
        end
      end
    end

    context 'when this is the last row to process' do
      let(:import) { Fabricate(:bulk_import, total_items: 2, processed_items: 1, imported_items: 0, state: :in_progress) }

      context 'with a clean failure' do
        include_context 'when service fails'
        it_behaves_like 'clean failure'

        it 'marks the import as finished' do
          expect { subject.perform(row.id) }
            .to change { import.reload.state.to_sym }.from(:in_progress).to(:finished)
        end
      end

      context 'with an unclean failure' do
        # NOTE: sidekiq retry logic may be a bit too difficult to test, so leaving this blind spot for now
        include_context 'when service errors'
        it_behaves_like 'unclean failure'
      end

      context 'with a clean success' do
        include_context 'when service succeeds'
        it_behaves_like 'clean success'

        it 'marks the import as finished' do
          expect { subject.perform(row.id) }
            .to change { import.reload.state.to_sym }.from(:in_progress).to(:finished)
        end
      end
    end
  end
end
