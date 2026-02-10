# frozen_string_literal: true

class PurgeCustomEmojiWorker
  include Sidekiq::IterableJob

  def build_enumerator(domain, cursor:)
    return if domain.blank?

    active_record_batches_enumerator(CustomEmoji.where(domain: domain), cursor:)
  end

  def each_iteration(custom_emojis, _domain)
    AttachmentBatch.new(CustomEmoji, custom_emojis).delete
  end
end
