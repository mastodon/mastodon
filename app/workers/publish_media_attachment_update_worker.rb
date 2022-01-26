# frozen_string_literal: true

class PublishMediaAttachmentUpdateWorker
  include Sidekiq::Worker

  def perform(media_attachment_id, updated_at)
    @media_attachment = MediaAttachment.find(media_attachment_id)
    @status           = media_attachment.status

    # This media attachment could have been detached, or the user might
    # have updated the status already, in which case we don't need to
    # do anything
    return if @status.nil? || @status.edited_at > updated_at.to_datetime

    Status.transaction do
      @status.snapshot!(media_attachments_changed: false, at_time: @status.created_at) unless @status.edits.any?
      @status.touch(:edited_at)
      @status.snapshot!(media_attachments_changed: true)
    end

    broadcast_updates!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def broadcast_updates!
    DistributionWorker.perform_async(@status.id, update: true)
    ActivityPub::StatusUpdateDistributionWorker.perform_async(@status.id)
  end
end
