# frozen_string_literal: true

module BrandingHelper
  def logo_as_symbol(version = :icon)
    case version
    when :icon
      _logo_as_symbol_icon
    when :wordmark
      _logo_as_symbol_wordmark
    end
  end

  def _logo_as_symbol_wordmark
    content_tag(:svg, tag.use(href: '#logo-symbol-wordmark'), viewBox: '0 0 261 66', class: 'logo logo--wordmark')
  end

  def _logo_as_symbol_icon
    content_tag(:svg, tag.use(href: '#logo-symbol-icon'), viewBox: '0 0 79 79', class: 'logo logo--icon')
  end

  def render_logo
    image_tag(frontend_asset_path('images/logo.svg'), alt: 'Mastodon', class: 'logo logo--icon')
  end
end
