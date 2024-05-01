# frozen_string_literal: true

module ThemeHelper
  def theme_style_tags(flavour_and_skin)
    flavour, theme = flavour_and_skin

    if theme == 'system'
      stylesheet_pack_tag("skins/#{flavour}/mastodon-light", media: 'not all and (prefers-color-scheme: dark)', crossorigin: 'anonymous') +
        stylesheet_pack_tag("skins/#{flavour}/default", media: '(prefers-color-scheme: dark)', crossorigin: 'anonymous')
    else
      stylesheet_pack_tag "skins/#{flavour}/#{theme}", media: 'all', crossorigin: 'anonymous'
    end
  end

  def theme_color_tags(flavour_and_skin)
    _, theme = flavour_and_skin

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
