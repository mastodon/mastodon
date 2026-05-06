# frozen_string_literal: true

class Vacuum::PreviewCardsVacuum
  TTL = 1.day.freeze

  def initialize(retention_period)
    @retention_period = retention_period
  end

  def perform
    vacuum_cached_images! if retention_period?
  end

  private

  def vacuum_cached_images!
    preview_cards_past_retention_period.find_in_batches do |preview_card|
      AttachmentBatch.new(PreviewCard, preview_card).clear
    rescue => e
      Rails.logger.error("Skipping batch while removing cached preview cards due to error: #{e}")
    end
  end

  def preview_cards_past_retention_period
    PreviewCard.cached.where(PreviewCard.arel_table[:updated_at].lt(@retention_period.ago))
  end

  def retention_period?
    @retention_period.present?
  end
end
