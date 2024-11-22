# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkImport do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to have_many(:rows).class_name('BulkImportRow').inverse_of(:bulk_import).dependent(:delete_all) }
  end

  describe 'Validations' do
    subject { Fabricate.build :bulk_import }

    it { is_expected.to validate_presence_of(:type) }
  end

  describe 'Scopes' do
    describe '.archival_completed' do
      let!(:old_import) { Fabricate :bulk_import, created_at: 1.month.ago }
      let!(:new_import) { Fabricate :bulk_import, created_at: 1.day.ago }

      it 'returns imports which have passed the archive window period' do
        expect(described_class.archival_completed)
          .to include(old_import)
          .and not_include(new_import)
      end
    end

    describe '.confirmation_missed' do
      let!(:old_unconfirmed_import) { Fabricate :bulk_import, created_at: 1.week.ago, state: :unconfirmed }
      let!(:old_scheduled_import) { Fabricate :bulk_import, created_at: 1.week.ago, state: :scheduled }
      let!(:new_unconfirmed_import) { Fabricate :bulk_import, created_at: 1.minute.ago, state: :unconfirmed }

      it 'returns imports which have passed the confirmation window without confirming' do
        expect(described_class.confirmation_missed)
          .to include(old_unconfirmed_import)
          .and not_include(old_scheduled_import)
          .and not_include(new_unconfirmed_import)
      end
    end
  end
end
