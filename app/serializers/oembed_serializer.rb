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
    account_url(object.account)
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
    tag :iframe,
        src: embed_account_stream_entry_url(object.account, object),
        style: 'width: 100%; overflow: hidden',
        frameborder: '0',
        scrolling: 'no',
        width: width,
        height: height
  end

  def width
    instance_options[:width]
  end

  def height
    instance_options[:height]
  end
end
