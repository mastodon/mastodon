# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::ImportsVacuum do
  subject { described_class.new }

  let!(:old_unconfirmed) { Fabricate(:bulk_import, state: :unconfirmed, created_at: 2.days.ago) }
  let!(:new_unconfirmed) { Fabricate(:bulk_import, state: :unconfirmed, created_at: 10.seconds.ago) }
  let!(:recent_ongoing)  { Fabricate(:bulk_import, state: :in_progress, created_at: 20.minutes.ago) }
  let!(:recent_finished) { Fabricate(:bulk_import, state: :finished, created_at: 1.day.ago) }
  let!(:old_finished)    { Fabricate(:bulk_import, state: :finished, created_at: 2.months.ago) }

  describe '#perform' do
    it 'cleans up the expected imports' do
      expect { subject.perform }
        .to change { ordered_bulk_imports.pluck(:id) }
        .from(original_import_ids)
        .to(remaining_import_ids)
    end

    def ordered_bulk_imports
      BulkImport.order(id: :asc)
    end

    def original_import_ids
      [old_unconfirmed, new_unconfirmed, recent_ongoing, recent_finished, old_finished].map(&:id)
    end

    def vacuumed_import_ids
      [old_unconfirmed, old_finished].map(&:id)
    end

    def remaining_import_ids
      original_import_ids - vacuumed_import_ids
    end
  end
end
