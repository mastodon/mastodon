# frozen_string_literal: true

class Maintenance::UncachePreviewWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(preview_card_id)
    preview_card = PreviewCard.find(preview_card_id)

    return if preview_card.image.blank?

    preview_card.image.destroy
    preview_card.save
  rescue ActiveRecord::RecordNotFound
    true
  end
end
