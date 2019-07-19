# frozen_string_literal: true

class Scheduler::PreviewCardsCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    Maintenance::UncachePreviewWorker.push_bulk(recent_link_preview_cards.pluck(:id))
    Maintenance::UncachePreviewWorker.push_bulk(older_preview_cards.pluck(:id))
  end

  private

  def recent_link_preview_cards
    PreviewCard.where(type: :link).where('updated_at < ?', 1.month.ago)
  end

  def older_preview_cards
    PreviewCard.where('updated_at < ?', 6.months.ago)
  end
end
