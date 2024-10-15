# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::PreviewCardsVacuum do
  subject { described_class.new(retention_period) }

  let(:retention_period) { 7.days }

  describe '#perform' do
    let!(:orphaned_preview_card) { Fabricate(:preview_card, created_at: 2.days.ago) }
    let!(:old_preview_card) { Fabricate(:preview_card, updated_at: (retention_period + 1.day).ago) }
    let!(:new_preview_card) { Fabricate(:preview_card) }

    before do
      old_preview_card.statuses << Fabricate(:status)
      new_preview_card.statuses << Fabricate(:status)
    end

    it 'handles preview card cleanup' do
      subject.perform

      expect(old_preview_card.reload.image) # last updated before retention period
        .to be_blank

      expect(new_preview_card.reload.image) # last updated within the retention period
        .to_not be_blank

      expect(new_preview_card.reload) # Keep attached preview cards
        .to be_persisted

      expect(orphaned_preview_card.reload) # keep orphaned cards in the retention period
        .to be_persisted
    end
  end
end
