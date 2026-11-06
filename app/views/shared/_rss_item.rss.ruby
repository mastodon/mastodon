# frozen_string_literal: true
# Render a single status as RSS item

doc.item do |item|
  item.link(ActivityPub::TagManager.instance.url_for(status))
  item.pub_date(status.created_at)
  item.description(rss_status_content_format(status))

  if status.ordered_media_attachments.first&.audio?
    media = status.ordered_media_attachments.first
    item.enclosure(full_asset_url(media.file.url(:original, false)), media.file.content_type, media.file.size)
  end

  status.ordered_media_attachments.each do |media_attachment|
    item.media_content(full_asset_url(media_attachment.file.url(:original, false)), media_attachment.file.content_type, media_attachment.file.size) do |media_content|
      media_content.medium(media_attachment.gifv? ? 'image' : media_attachment.type.to_s)
      media_content.rating(status.sensitive? ? 'adult' : 'nonadult')
      media_content.description(media_attachment.description) if media_attachment.description.present?
      media_content.thumbnail(full_asset_url(media_attachment.thumbnail.present? ? media_attachment.thumbnail.url : media_attachment.file.url(:small)))
    end
  end

  status.tags.each do |tag|
    item.category(tag.display_name)
  end
end
