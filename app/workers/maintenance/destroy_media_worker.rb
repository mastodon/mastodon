# frozen_string_literal: true

class Maintenance::DestroyMediaWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(media_attachment_id)
    media = MediaAttachment.find(media_attachment_id)
    media.destroy
  rescue ActiveRecord::RecordNotFound
    true
  end
end
