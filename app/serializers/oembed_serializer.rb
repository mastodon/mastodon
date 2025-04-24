# frozen_string_literal: true

class OEmbedSerializer < ActiveModel::Serializer
  INLINE_STYLES = {
    blockquote: <<~CSS.squish,
      background: #FCF8FF;
      border-radius: 8px;
      border: 1px solid #C9C4DA;
      margin: 0;
      max-width: 540px;
      min-width: 270px;
      overflow: hidden;
      padding: 0;
    CSS
    status_link: <<~CSS.squish,
      align-items: center;
      color: #1C1A25;
      display: flex;
      flex-direction: column;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Oxygen, Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans', 'Helvetica Neue', Roboto, sans-serif;
      font-size: 14px;
      justify-content: center;
      letter-spacing: 0.25px;
      line-height: 20px;
      padding: 24px;
      text-decoration: none;
    CSS
    div_account: <<~CSS.squish,
      color: #787588;
      margin-top: 16px;
    CSS
    div_view: <<~CSS.squish,
      font-weight: 500;
    CSS
  }.freeze

  DEFAULT_WIDTH = 400

  include RoutingHelper
  include ActionView::Helpers::TagHelper

  attributes :type, :version, :author_name,
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
    <<~HTML.squish
      <blockquote class="mastodon-embed" data-embed-url="#{embed_short_account_status_url(object.account, object)}" style="#{INLINE_STYLES[:blockquote]}">
        <a href="#{short_account_status_url(object.account, object)}" target="_blank" style="#{INLINE_STYLES[:status_link]}">
          <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="32" height="32" viewBox="0 0 79 75"><path d="M63 45.3v-20c0-4.1-1-7.3-3.2-9.7-2.1-2.4-5-3.7-8.5-3.7-4.1 0-7.2 1.6-9.3 4.7l-2 3.3-2-3.3c-2-3.1-5.1-4.7-9.2-4.7-3.5 0-6.4 1.3-8.6 3.7-2.1 2.4-3.1 5.6-3.1 9.7v20h8V25.9c0-4.1 1.7-6.2 5.2-6.2 3.8 0 5.8 2.5 5.8 7.4V37.7H44V27.1c0-4.9 1.9-7.4 5.8-7.4 3.5 0 5.2 2.1 5.2 6.2V45.3h8ZM74.7 16.6c.6 6 .1 15.7.1 17.3 0 .5-.1 4.8-.1 5.3-.7 11.5-8 16-15.6 17.5-.1 0-.2 0-.3 0-4.9 1-10 1.2-14.9 1.4-1.2 0-2.4 0-3.6 0-4.8 0-9.7-.6-14.4-1.7-.1 0-.1 0-.1 0s-.1 0-.1 0 0 .1 0 .1 0 0 0 0c.1 1.6.4 3.1 1 4.5.6 1.7 2.9 5.7 11.4 5.7 5 0 9.9-.6 14.8-1.7 0 0 0 0 0 0 .1 0 .1 0 .1 0 0 .1 0 .1 0 .1.1 0 .1 0 .1.1v5.6s0 .1-.1.1c0 0 0 0 0 .1-1.6 1.1-3.7 1.7-5.6 2.3-.8.3-1.6.5-2.4.7-7.5 1.7-15.4 1.3-22.7-1.2-6.8-2.4-13.8-8.2-15.5-15.2-.9-3.8-1.6-7.6-1.9-11.5-.6-5.8-.6-11.7-.8-17.5C3.9 24.5 4 20 4.9 16 6.7 7.9 14.1 2.2 22.3 1c1.4-.2 4.1-1 16.5-1h.1C51.4 0 56.7.8 58.1 1c8.4 1.2 15.5 7.5 16.6 15.6Z" fill="currentColor"/></svg>
          <div style="#{INLINE_STYLES[:div_account]}">Post by @#{object.account.pretty_acct}@#{provider_name}</div>
          <div style="#{INLINE_STYLES[:div_view]}">View on Mastodon</div>
        </a>
      </blockquote>
      <script data-allowed-prefixes="#{root_url}" async src="#{full_asset_url('embed.js', skip_pipeline: true)}"></script>
    HTML
  end

  def width
    (instance_options[:width] || DEFAULT_WIDTH).to_i
  end

  def height
    instance_options[:height].presence&.to_i
  end
end
