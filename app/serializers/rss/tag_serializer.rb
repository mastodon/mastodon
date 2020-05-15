# frozen_string_literal: true

class RSS::TagSerializer < RSS::Serializer
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper
  include RoutingHelper

  def render(tag, statuses)
    builder = RSSBuilder.new

    builder.title("##{tag.name}")
           .description(strip_tags(I18n.t('about.about_hashtag_html', hashtag: tag.name)))
           .link(tag_url(tag))
           .logo(full_pack_url('media/images/logo.svg'))
           .accent_color('2b90d9')

    render_statuses(builder, statuses)

    builder.to_xml
  end

  def self.render(tag, statuses)
    new.render(tag, statuses)
  end
end
