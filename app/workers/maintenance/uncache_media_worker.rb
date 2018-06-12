# frozen_string_literal: true

class Maintenance::UncacheMediaWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(media_attachment_id)
    media = MediaAttachment.find(media_attachment_id)

    return unless media.file.exists?

    media.file.destroy
    media.save
  rescue ActiveRecord::RecordNotFound
    true
  end
end
