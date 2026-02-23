# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::StatusBatchAction do
  subject do
    described_class.new(
      current_account:,
      type:,
      status_ids:,
      report_id:,
      text:
    )
  end

  let(:current_account) { Fabricate(:admin_user).account }
  let(:target_account) { Fabricate(:account) }
  let(:statuses) { Fabricate.times(2, :status, account: target_account) }
  let(:status_ids) { statuses.map(&:id) }
  let(:report) { Fabricate(:report, target_account:, status_ids:) }
  let(:report_id) { report.id }
  let(:text) { 'test' }

  describe '#save!' do
    context 'when `type` is `delete`' do
      let(:type) { 'delete' }

      it 'discards the statuses' do
        subject.save!

        statuses.each do |status|
          expect(status.reload).to be_discarded
        end
        expect(report.reload).to be_action_taken
      end
    end

    context 'when `type` is `mark_as_sensitive`' do
      let(:type) { 'mark_as_sensitive' }

      before do
        preview_card = Fabricate(:preview_card)
        statuses.each do |status|
          PreviewCardsStatus.create!(status:, preview_card:)
        end
      end

      it 'marks the statuses as sensitive' do
        subject.save!

        statuses.each do |status|
          expect(status.reload).to be_sensitive
        end
        expect(report.reload).to be_action_taken
      end
    end

    context 'when `type` is `report`' do
      let(:report_id) { nil }
      let(:type) { 'report' }

      it 'creates a report' do
        expect { subject.save! }.to change(Report, :count).by(1)

        new_report = Report.last
        expect(new_report.status_ids).to match_array(status_ids)
      end
    end

    context 'when `type` is `remove_from_report`' do
      let(:type) { 'remove_from_report' }

      it 'removes the statuses from the report' do
        subject.save!

        expect(report.reload.status_ids).to be_empty
      end
    end
  end
end
