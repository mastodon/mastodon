RSS::Builder.build do |doc|
  doc.title("##{@tag.name}")
  doc.description(I18n.t('rss.descriptions.tag', hashtag: @tag.name))
  doc.link(tag_url(@tag))
  doc.last_build_date(@statuses.first.created_at) if @statuses.any?

  @statuses.each do |status|
    doc.item do |item|
      item.title(l(status.created_at))
      item.link(ActivityPub::TagManager.instance.url_for(status))
      item.pub_date(status.created_at)
      item.description(rss_status_content_format(status))

      if status.ordered_media_attachments.first&.audio?
        media = status.ordered_media_attachments.first
        item.enclosure(full_asset_url(media.file.url(:original, false)), media.file.content_type, media.file.size)
      end

      status.ordered_media_attachments.each do |media|
        item.media_content(full_asset_url(media.file.url(:original, false)), media.file.content_type, media.file.size) do |media_content|
          media_content.medium(media.gifv? ? 'image' : media.type.to_s)
          media_content.rating(status.sensitive? ? 'adult' : 'nonadult')
          media_content.description(media.description) if media.description.present?
          media_content.thumbnail(media.thumbnail.url(:original, false)) if media.thumbnail?
        end
      end

      status.tags.each do |tag|
        item.category(tag.name)
      end
    end
  end
end
