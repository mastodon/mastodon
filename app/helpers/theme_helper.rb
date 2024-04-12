# frozen_string_literal: true

module ThemeHelper
  def theme_style_tags(theme)
    if theme == 'system'
      vite_stylesheet_tag('styles/mastodon-light.scss', media: 'not all and (prefers-color-scheme: dark)', crossorigin: 'anonymous') +
        vite_stylesheet_tag('styles/application.scss', media: '(prefers-color-scheme: dark)', crossorigin: 'anonymous')
    else
      vite_stylesheet_tag "styles/#{theme}.scss", media: 'all', crossorigin: 'anonymous'
    end
  end

  def theme_color_tags(theme)
    if theme == 'system'
      tag.meta(name: 'theme-color', content: Themes::THEME_COLORS[:dark], media: '(prefers-color-scheme: dark)') +
        tag.meta(name: 'theme-color', content: Themes::THEME_COLORS[:light], media: '(prefers-color-scheme: light)')
    else
      tag.meta name: 'theme-color', content: theme_color_for(theme)
    end
  end

  private

  def theme_color_for(theme)
    theme == 'mastodon-light' ? Themes::THEME_COLORS[:light] : Themes::THEME_COLORS[:dark]
  end
end
