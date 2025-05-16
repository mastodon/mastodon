# frozen_string_literal: true

module ThemeHelper
  def theme_style_tags(theme)
    if theme == 'system'
      ''.html_safe.tap do |tags|
        tags << vite_stylesheet_tag('styles/mastodon-light.scss', media: 'not all and (prefers-color-scheme: dark)', crossorigin: 'anonymous')
        tags << vite_stylesheet_tag('styles/application.scss', media: '(prefers-color-scheme: dark)', crossorigin: 'anonymous')
      end
    elsif theme == 'default'
      vite_stylesheet_tag 'styles/application.scss', media: 'all', crossorigin: 'anonymous'
    else
      vite_stylesheet_tag "styles/#{theme}.scss", media: 'all', crossorigin: 'anonymous'
    end
  end

  def theme_color_tags(theme)
    if theme == 'system'
      ''.html_safe.tap do |tags|
        tags << tag.meta(name: 'theme-color', content: Themes::THEME_COLORS[:dark], media: '(prefers-color-scheme: dark)')
        tags << tag.meta(name: 'theme-color', content: Themes::THEME_COLORS[:light], media: '(prefers-color-scheme: light)')
      end
    else
      tag.meta name: 'theme-color', content: theme_color_for(theme)
    end
  end

  def custom_stylesheet
    if active_custom_stylesheet.present?
      stylesheet_link_tag(
        custom_css_path(active_custom_stylesheet),
        host: root_url,
        media: :all,
        skip_pipeline: true
      )
    end
  end

  private

  def active_custom_stylesheet
    if cached_custom_css_digest.present?
      [:custom, cached_custom_css_digest.to_s.first(8)]
        .compact_blank
        .join('-')
    end
  end

  def cached_custom_css_digest
    Rails.cache.fetch(:setting_digest_custom_css) do
      Setting.custom_css&.then { |content| Digest::SHA256.hexdigest(content) }
    end
  end

  def theme_color_for(theme)
    theme == 'mastodon-light' ? Themes::THEME_COLORS[:light] : Themes::THEME_COLORS[:dark]
  end
end
