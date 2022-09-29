# frozen_string_literal: true

class Vacuum::PreviewCardsVacuum
  TTL = 1.day.freeze

  def initialize(retention_period)
    @retention_period = retention_period
  end

  def perform
    vacuum_cached_images! if retention_period?
    vacuum_orphaned_records!
  end

  private

  def vacuum_cached_images!
    preview_cards_past_retention_period.find_each do |preview_card|
      preview_card.image.destroy
      preview_card.save
    end
  end

  def vacuum_orphaned_records!
    orphaned_preview_cards.in_batches.destroy_all
  end

  def preview_cards_past_retention_period
    PreviewCard.cached.where(PreviewCard.arel_table[:updated_at].lt(@retention_period.ago))
  end

  def orphaned_preview_cards
    PreviewCard.where('NOT EXISTS (SELECT 1 FROM preview_cards_statuses WHERE preview_cards_statuses.preview_card_id = preview_cards.id)').where(PreviewCard.arel_table[:created_at].lt(TTL.ago))
  end

  def retention_period?
    @retention_period.present?
  end
end
