# frozen_string_literal: true

module Status::SearchConcern
  extend ActiveSupport::Concern

  included do
    scope :indexable, -> { without_reblogs.public_visibility.joins(:account).where(account: { indexable: true }) }
  end

  def searchable_by
    @searchable_by ||= begin
      [].tap do |account_ids|
        account_ids << account_id if local?
        searchable_by_sources.each { |source| account_ids << source.pluck(:id) }
      end.uniq
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
    searchable_properties_map
      .select { |_, value| value }
      .keys
      .map(&:to_s)
  end

  private

  def searchable_by_sources
    [
      local_bookmarked,
      local_favorited,
      local_mentioned,
      local_reblogged,
    ].tap do |list|
      list << preloadable_poll.local_voters if preloadable_poll.present?
    end
  end

  def searchable_properties_map
    {
      audio: ordered_media_attachments.any?(&:audio?),
      image: ordered_media_attachments.any?(&:image?),
      video: ordered_media_attachments.any?(&:video?),
      embed: preview_card&.video?,
      link: with_preview_card?,
      media: with_media?,
      poll: with_poll?,
      reply: reply?,
      sensitive: sensitive?,
    }
  end
end
