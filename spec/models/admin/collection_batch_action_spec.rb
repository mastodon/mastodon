# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CollectionBatchAction do
  subject do
    described_class.new(
      current_account:,
      collection_ids:,
      report_id:,
      type:
    )
  end

  let(:account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }
  let(:current_account) { Fabricate(:admin_user).account }
  let(:collection) { Fabricate(:collection, account: account) }
  let(:collection_ids) { [collection.id] }
  let(:report) { Fabricate(:report, account: target_account, target_account: account) }
  let(:type) { 'report' }

  before 'create collection report' do
    report.collections << collection
    report.save!
  end

  describe '#save!' do
    context 'when with_report? is true' do
      let(:other_collection) { Fabricate(:collection, account: account) }
      let(:report_id) { report.id }

      it 'creates no report and adds the collection to the existing report' do
        collection_ids << other_collection.id

        expect { subject.save! }.to_not change(Report, :count)
        expect(report.collections).to include(other_collection)
      end
    end

    context 'when with_report? is false' do
      let(:report_id) { nil }

      it 'creates a new report from the collection_ids' do
        expect { subject.save! }.to change(Report, :count).by(1)
        expect(Report.last.collections).to include(collection)
      end
    end

    context 'when type is remove_from_report' do
      let(:report_id) { report.id }
      let(:type) { 'remove_from_report' }

      it 'does not remove report but removes collection' do
        expect { subject.save! }.to_not change(Report, :count)
        expect(report.collections).to eq([])
      end
    end
  end
end
