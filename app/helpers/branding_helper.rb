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
    logo_url = InstancePresenter.new.logo&.file&.url
    tag = logo_url.present? ? tag.img('src' => logo_url) : nil
    tag || content_tag(:svg, tag.use(href: '#decodon-logo'), viewBox: '0 0 376 102', class: 'logo logo--wordmark')
    # content_tag(:svg, tag.use(href: '#logo-symbol-wordmark'), viewBox: '0 0 261 66', class: 'logo logo--wordmark')
  end

  def _logo_as_symbol_icon
    logo_url = InstancePresenter.new.logo&.file&.url
    tag = logo_url.present? ? tag.img('src' => logo_url) : nil
    tag || content_tag(:svg, tag.use(href: '#decodon-flower-logo'), viewBox: '0 0 150 150', class: 'logo logo--icon')
    # content_tag(:svg, tag.use(href: '#logo-symbol-icon'), viewBox: '0 0 79 79', class: 'logo logo--icon')
  end

  def render_logo
    content_tag(:svg, tag.use(href: '#decodon-flower-logo'), viewBox: '0 0 150 150', class: 'logo logo--icon')
  end

  def render_symbol(version = :icon)
    path = case version
           when :icon
             'decodon_flower_logo.svg'
           when :wordmark
             'decodon_logo_full.svg'
           end

    render(file: Rails.root.join('app', 'javascript', 'images', path)).html_safe # rubocop:disable Rails/OutputSafety
  end
end
