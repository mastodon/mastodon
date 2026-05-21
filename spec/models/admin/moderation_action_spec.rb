# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ModerationAction do
  subject do
    described_class.new(
      current_account:,
      type:,
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

      context 'with attached collections', feature: :collections do
        let(:status_ids) { [] }
        let(:collections) { Fabricate.times(2, :collection, account: target_account) }

        before do
          report.collections = collections
        end

        it 'deletes the collections and creates an action log' do
          expect { subject.save! }.to change(Collection, :count).by(-2)
            .and change(Admin::ActionLog, :count).by(3)
        end
      end

      context 'with a remote collection', feature: :collections do
        let(:status_ids) { [] }
        let(:collection) { Fabricate(:remote_collection) }
        let(:target_account) { collection.account }

        before do
          report.collections << collection
        end

        it 'creates a tombstone' do
          expect { subject.save! }.to change(Tombstone, :count).by(1)

          expect(Tombstone.last.uri).to eq collection.uri
        end
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

      context 'with attached collections', feature: :collections do
        let(:status_ids) { [] }
        let(:collections) { Fabricate.times(2, :collection, account: target_account) }

        before do
          report.collections = collections
        end

        it 'marks the collections as sensitive' do
          subject.save!

          collections.each do |collection|
            expect(collection.reload).to be_sensitive
          end
          expect(report.reload).to be_action_taken
        end
      end
    end
  end
end
