# frozen_string_literal: true

class Vacuum::MediaAttachmentsVacuum
  TTL = 1.day.freeze

  def initialize(retention_period)
    @retention_period = retention_period
  end

  def perform
    vacuum_orphaned_records!
    vacuum_cached_files! if retention_period?
  end

  private

  def vacuum_cached_files!
    Paperclip::AttachmentExtensions.start_batch
    media_attachments_past_retention_period.find_each do |media_attachment|
      media_attachment.file.destroy
      media_attachment.thumbnail.destroy
      media_attachment.save
    end
    Paperclip::AttachmentExtensions.end_batch
  end

  def vacuum_orphaned_records!
    orphaned_media_attachments.in_batches.destroy_all
  end

  def media_attachments_past_retention_period
    MediaAttachment.unscoped.remote.cached.where(MediaAttachment.arel_table[:created_at].lt(@retention_period.ago)).where(MediaAttachment.arel_table[:updated_at].lt(@retention_period.ago))
  end

  def orphaned_media_attachments
    MediaAttachment.unscoped.unattached.where(MediaAttachment.arel_table[:created_at].lt(TTL.ago))
  end

  def retention_period?
    @retention_period.present?
  end
end
