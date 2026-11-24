# frozen_string_literal: true

module BrandingHelper
  def render_logo
    image_tag(frontend_asset_path('images/logo.svg'), alt: 'Mastodon', class: 'logo logo--icon')
  end

  def logo_as_symbol_icon
    inline_svg_tag 'logo-symbol-icon.svg', class: 'logo logo--icon', view_box: '0 0 79 79'
  end

  def logo_as_symbol_wordmark
    inline_svg_tag 'logo-symbol-wordmark.svg', class: 'logo logo--wordmark', title: 'Mastodon'
  end
end
