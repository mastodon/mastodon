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

      subject.perform
    end

    it 'deletes cache of preview cards last updated before the retention period' do
      expect(old_preview_card.reload.image).to be_blank
    end

    it 'does not delete cache of preview cards last updated within the retention period' do
      expect(new_preview_card.reload.image).to_not be_blank
    end

    it 'does not delete attached preview cards' do
      expect(new_preview_card.reload).to be_persisted
    end
  end
end
