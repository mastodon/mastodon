object false

node(:name)        { Setting.site_title }
node(:description) { strip_tags(Setting.site_description.presence || I18n.t('about.about_mastodon')) }
node(:icons)       { [{ src: '/android-chrome-192x192.png', sizes: '192x192', type: 'image/png' }] }
node(:theme_color) { '#282c37' }
node(:display)     { 'standalone' }
node(:start_url)   { '/web/timelines/home' }
node(:scope)       { root_url }
