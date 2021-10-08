# frozen_string_literal: true

class PostProcessMediaWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, dead: false

  sidekiq_retries_exhausted do |msg|
    media_attachment_id = msg['args'].first

    ActiveRecord::Base.connection_pool.with_connection do
      begin
        media_attachment = MediaAttachment.find(media_attachment_id)
        media_attachment.processing = :failed
        media_attachment.save
      rescue ActiveRecord::RecordNotFound
        true
      end
    end

    Sidekiq.logger.error("Processing media attachment #{media_attachment_id} failed with #{msg['error_message']}")
  end

  def perform(media_attachment_id)
    media_attachment = MediaAttachment.find(media_attachment_id)
    media_attachment.processing = :in_progress
    media_attachment.save

    # Because paperclip-av-transcover overwrites this attribute
    # we will save it here and restore it after reprocess is done
    previous_meta = media_attachment.file_meta

    media_attachment.file.reprocess!(:original)
    media_attachment.processing = :complete
    media_attachment.file_meta = previous_meta.merge(media_attachment.file_meta).with_indifferent_access.slice(*MediaAttachment::META_KEYS)
    media_attachment.save
  rescue ActiveRecord::RecordNotFound
    true
  end
end
