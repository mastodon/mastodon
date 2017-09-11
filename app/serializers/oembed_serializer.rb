# frozen_string_literal: true

class OEmbedSerializer < ActiveModel::Serializer
  include RoutingHelper
  include ActionView::Helpers::TagHelper

  attributes :type, :version, :title, :author_name,
             :author_url, :provider_name, :provider_url,
             :cache_age, :html, :width, :height

  def type
    'rich'
  end

  def version
    '1.0'
  end

  def author_name
    object.account.display_name.presence || object.account.username
  end

  def author_url
    short_account_url(object.account)
  end

  def provider_name
    Rails.configuration.x.local_domain
  end

  def provider_url
    root_url
  end

  def cache_age
    86_400
  end

  def html
    attributes = {
      src: embed_short_account_status_url(object.account, object),
      class: 'mastodon-embed',
      style: 'max-width: 100%; border: 0',
      width: width,
      height: height,
    }

    content_tag(:iframe, nil, attributes) + content_tag(:script, nil, src: full_asset_url('embed.js'), async: true)
  end

  def width
    instance_options[:width]
  end

  def height
    instance_options[:height]
  end
end
