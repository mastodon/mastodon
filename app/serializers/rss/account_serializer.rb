# frozen_string_literal: true

class RSS::AccountSerializer
  include ActionView::Helpers::NumberHelper
  include StatusesHelper
  include RoutingHelper

  def render(account, statuses)
    builder = RSSBuilder.new

    builder.title("#{display_name(account)} (@#{account.local_username_and_domain})")
           .description(account_description(account))
           .link(ActivityPub::TagManager.instance.url_for(account))
           .logo(full_pack_url('media/images/logo.svg'))
           .accent_color('2b90d9')

    builder.image(full_asset_url(account.avatar.url(:original))) if account.avatar?
    builder.cover(full_asset_url(account.header.url(:original))) if account.header?

    statuses.each do |status|
      builder.item do |item|
        item.title(status.title)
            .link(ActivityPub::TagManager.instance.url_for(status))
            .pub_date(status.created_at)
            .description(status.spoiler_text.presence || Formatter.instance.format(status, inline_poll_options: true).to_str)

        status.media_attachments.each do |media|
          item.enclosure(full_asset_url(media.file.url(:original, false)), media.file.content_type, length: media.file.size)
        end
      end
    end

    builder.to_xml
  end

  def self.render(account, statuses)
    new.render(account, statuses)
  end
end
