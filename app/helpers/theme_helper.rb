# frozen_string_literal: true

module ThemeHelper
  def theme_style_tags(theme)
    if theme == 'system'
      system_theme_style_tags
    else
      stylesheet_pack_tag theme, media: 'all', crossorigin: 'anonymous'
    end
  end

  def theme_color_tags(theme)
    if theme == 'system'
      system_theme_color_tags
    else
      tag.meta name: 'theme-color', content: theme_color_for(theme)
    end
  end

  private

  def system_theme_style_tags
    ''.html_safe.tap do |tags|
      system_default_styles.each do |style|
        tags << stylesheet_pack_tag(
          style[:name],
          crossorigin: 'anonymous',
          media: style[:media]
        )
      end
    end
  end

  def system_theme_color_tags
    ''.html_safe.tap do |tags|
      %i(dark light).each do |scheme|
        tags << tag.meta(
          content: Themes::THEME_COLORS[scheme],
          media: "(prefers-color-scheme: #{scheme})",
          name: 'theme-color'
        )
      end
    end
  end

  def theme_color_for(theme)
    theme == 'mastodon-light' ? Themes::THEME_COLORS[:light] : Themes::THEME_COLORS[:dark]
  end

  def system_default_styles
    [
      { name: 'mastodon-light', media: 'not all and (prefers-color-scheme: dark)' },
      { name: 'default', media: '(prefers-color-scheme: dark)' },
    ]
  end
end
