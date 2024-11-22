# frozen_string_literal: true

RSS::Builder.build do |doc|
  doc.title(display_name(@account))
  doc.description(I18n.t('rss.descriptions.account', acct: @account.local_username_and_domain))
  doc.link(params[:tag].present? ? short_account_tag_url(@account, params[:tag]) : short_account_url(@account))
  doc.image(full_asset_url(@account.avatar.url(:original)), display_name(@account), params[:tag].present? ? short_account_tag_url(@account, params[:tag]) : short_account_url(@account))
  doc.last_build_date(@statuses.first.created_at) if @statuses.any?
  doc.icon(full_asset_url(@account.avatar.url(:original)))
  doc.generator("Mastodon v#{Mastodon::Version}")

  @statuses.each do |status|
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
          media_content.thumbnail(media_attachment.thumbnail.url(:original, false)) if media_attachment.thumbnail?
        end
      end

      status.tags.each do |tag|
        item.category(tag.display_name)
      end
    end
  end
end
