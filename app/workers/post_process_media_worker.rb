# frozen_string_literal: true

class PostProcessMediaWorker
  include Sidekiq::Worker
  include Lockable

  sidekiq_options retry: 1, dead: false

  MAX_PROCESSING_TIME = 15.minutes

  sidekiq_retries_exhausted do |msg|
    media_attachment_id = msg['args'].first

    ActiveRecord::Base.connection_pool.with_connection do
      media_attachment = MediaAttachment.find(media_attachment_id)
      media_attachment.processing = :failed
      media_attachment.save
    rescue ActiveRecord::RecordNotFound
      true
    end

    Sidekiq.logger.error("Processing media attachment #{media_attachment_id} failed with #{msg['error_message']}")
  end

  def perform(media_attachment_id)
    media_attachment = MediaAttachment.find(media_attachment_id)

    return true if media_attachment.processing_complete?

    with_redis_lock("post_process_media:#{media_attachment_id}", autorelease: MAX_PROCESSING_TIME, raise_on_failure: false) do
      media_attachment.reload

      return true if media_attachment.processing_complete?

      return true if media_attachment.processing_in_progress? && !processing_stuck?(media_attachment)

      media_attachment.processing = :in_progress
      media_attachment.save!

      previous_meta = media_attachment.file_meta

      media_attachment.file.reprocess!(:original)
      media_attachment.processing = :complete
      media_attachment.file_meta = previous_meta.merge(media_attachment.file_meta).with_indifferent_access.slice(*MediaAttachment::META_KEYS)
      media_attachment.save!
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def processing_stuck?(media_attachment)
    media_attachment.updated_at < MAX_PROCESSING_TIME.ago
  end
end
