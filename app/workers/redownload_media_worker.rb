# frozen_string_literal: true

class RedownloadMediaWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(id)
    media_attachment = MediaAttachment.find(id)

    return if media_attachment.remote_url.blank?

    media_attachment.file_remote_url = media_attachment.remote_url
    media_attachment.save
  rescue ActiveRecord::RecordNotFound
    true
  end
end
