# frozen_string_literal: true

class ManifestSerializer < ActiveModel::Serializer
  include RoutingHelper
  include ActionView::Helpers::TextHelper

  attributes :name, :short_name, :description,
             :icons, :theme_color, :background_color,
             :display, :start_url, :scope,
             :share_target, :shortcuts

  def name
    object.site_title
  end

  def short_name
    object.site_title
  end

  def description
    strip_tags(object.site_short_description.presence || I18n.t('about.about_mastodon_html'))
  end

  def icons
    [
      {
        src: '/android-chrome-192x192.png',
        sizes: '192x192',
        type: 'image/png',
        purpose: 'any',
      },
      {
        src: '/maskable-icon-200x200.png',
        sizes: '200x200',
        type: 'image/png',
        purpose: 'maskable',
      },
    ]
  end

  def theme_color
    '#282c37'
  end

  def background_color
    '#191b22'
  end

  def display
    'standalone'
  end

  def start_url
    '/web/home'
  end

  def scope
    '/'
  end

  def share_target
    {
      url_template: 'share?title={title}&text={text}&url={url}',
      action: 'share',
      method: 'GET',
      enctype: 'application/x-www-form-urlencoded',
      params: {
        title: 'title',
        text: 'text',
        url: 'url',
      },
    }
  end

  def shortcuts
    [
      {
        name: 'New toot',
        url: '/web/publish',
        icons: [
          {
            src: '/shortcuts/new-status.png',
            type: 'image/png',
            sizes: '192x192',
          },
        ],
      },
      {
        name: 'Notifications',
        url: '/web/notifications',
        icons: [
          {
            src: '/shortcuts/notifications.png',
            type: 'image/png',
            sizes: '192x192',
          },
        ],
      },
      {
        name: 'Direct messages',
        url: '/web/conversations',
        icons: [
          {
            src: '/shortcuts/direct.png',
            type: 'image/png',
            sizes: '192x192',
          },
        ],
      },
    ]
  end
end
