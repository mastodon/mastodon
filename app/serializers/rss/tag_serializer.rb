# frozen_string_literal: true

class RSS::TagSerializer
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper
  include StatusesHelper
  include RoutingHelper

  def render(tag, statuses)
    builder = RSSBuilder.new

    builder.title("##{tag.name}")
           .description(strip_tags(I18n.t('about.about_hashtag_html', hashtag: tag.name)))
           .link(tag_url(tag))
           .logo(full_pack_url('media/images/logo.svg'))
           .accent_color('2b90d9')

    statuses.each do |status|
      builder.item do |item|
        item.title(status.title)
            .link(ActivityPub::TagManager.instance.url_for(status))
            .pub_date(status.created_at)
            .description(status.spoiler_text.presence || Formatter.instance.format(status).to_str)

        status.media_attachments.each do |media|
          item.enclosure(full_asset_url(media.file.url(:original, false)), media.file.content_type, media.file.size)
        end
      end
    end

    builder.to_xml
  end

  def self.render(tag, statuses)
    new.render(tag, statuses)
  end
end
