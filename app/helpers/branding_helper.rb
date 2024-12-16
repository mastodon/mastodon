# frozen_string_literal: true

module BrandingHelper
  def logo_as_symbol(version = :icon)
    case version
    when :icon
      _logo_as_symbol_icon
    when :wordmark
      render_logo
    end
  end

  def _logo_as_symbol_wordmark
    content_tag(:svg, tag.use(href: '#decodon-logo'), viewBox: '0 0 376 102', class: 'logo logo--wordmark')
  end

  def _logo_as_symbol_icon
    content_tag(:svg, tag.use(href: '#decodon-flower-logo'), viewBox: '0 0 150 150', class: 'logo logo--icon')
  end

  def render_logo
    image_tag(frontend_asset_path('images/logo.svg'), alt: 'frequency', class: 'logo logo--icon')
  end
end
