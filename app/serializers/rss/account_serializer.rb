# frozen_string_literal: true

class RSS::AccountSerializer < RSS::Serializer
  include ActionView::Helpers::NumberHelper
  include AccountsHelper
  include RoutingHelper

  def render(account, statuses, tag)
    builder = RSSBuilder.new

    builder.title("#{display_name(account)} (@#{account.local_username_and_domain})")
           .description(account_description(account))
           .link(tag.present? ? short_account_tag_url(account, tag) : short_account_url(account))
           .logo(full_pack_url('media/images/logo.svg'))
           .accent_color('2b90d9')

    builder.image(full_asset_url(account.avatar.url(:original))) if account.avatar?
    builder.cover(full_asset_url(account.header.url(:original))) if account.header?

    render_statuses(builder, statuses)

    builder.to_xml
  end

  def self.render(account, statuses, tag)
    new.render(account, statuses, tag)
  end
end
