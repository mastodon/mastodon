# frozen_string_literal: true

module Status::SearchConcern
  extend ActiveSupport::Concern

  included do
    scope :indexable, -> { without_reblogs.public_visibility.joins(:account).where(account: { indexable: true }) }
  end

  def searchable_by
    @searchable_by ||= begin
      ids = []

      ids << account_id if local?

      ids += local_mentioned.pluck(:id)
      ids += local_favorited.pluck(:id)
      ids += local_reblogged.pluck(:id)
      ids += local_bookmarked.pluck(:id)
      ids += preloadable_poll.local_voters.pluck(:id) if preloadable_poll.present?

      ids.uniq
    end
  end

  def searchable_text
    [
      spoiler_text,
      FormattingHelper.extract_status_plain_text(self),
      preloadable_poll&.options&.join("\n\n"),
      ordered_media_attachments.map(&:description).join("\n\n"),
    ].compact.join("\n\n")
  end

  def searchable_properties
    [].tap do |properties|
      properties << 'image' if ordered_media_attachments.any?(&:image?)
      properties << 'video' if ordered_media_attachments.any?(&:video?)
      properties << 'audio' if ordered_media_attachments.any?(&:audio?)
      properties << 'media' if with_media?
      properties << 'poll' if with_poll?
      properties << 'link' if with_preview_card?
      properties << 'embed' if preview_card&.video?
      properties << 'sensitive' if sensitive?
      properties << 'reply' if reply?
    end
  end
end
