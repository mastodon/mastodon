# frozen_string_literal: true

module StatusSearchConcern
  extend ActiveSupport::Concern

  def searchable_by(preloaded = nil)
    ids = []

    ids << account_id if local?

    if preloaded.nil?
      ids += mentions.joins(:account).merge(Account.local).active.pluck(:account_id)
      ids += favourites.joins(:account).merge(Account.local).pluck(:account_id)
      ids += reblogs.joins(:account).merge(Account.local).pluck(:account_id)
      ids += bookmarks.joins(:account).merge(Account.local).pluck(:account_id)
      ids += poll.votes.joins(:account).merge(Account.local).pluck(:account_id) if poll.present?
    else
      ids += preloaded.mentions[id] || []
      ids += preloaded.favourites[id] || []
      ids += preloaded.reblogs[id] || []
      ids += preloaded.bookmarks[id] || []
      ids += preloaded.votes[id] || []
    end

    ids.uniq
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
      properties << 'embed' if preview_cards.any?(&:video?)
      properties << 'sensitive' if sensitive?
      properties << 'reply' if reply?
    end
  end
end
