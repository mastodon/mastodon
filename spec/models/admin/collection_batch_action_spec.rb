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

  before 'create colelction report' do
    report.collections << collection
    report.save!
  end

  describe '#save!' do
    context 'when with_report? is true' do
      let(:report_id) { report.id }

      it 'creates no report' do
        expect { subject.save! }.to_not change(Report, :count)
      end
    end

    context 'when with_report? is false' do
      let(:report_id) { nil }

      it 'creates no report' do
        expect { subject.save! }.to change(Report, :count).by(1)
      end
    end
  end
end
