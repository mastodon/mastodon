import inherited from 'mastodon/locales/en.json';

const messages = {
  'getting_started.open_source_notice': 'Glitchsoc is free open source software forked from {Mastodon}. You can contribute or report issues on GitHub at {github}.',
  'layout.auto': 'Auto',
  'layout.current_is': 'Your current layout is:',
  'layout.desktop': 'Desktop',
  'layout.mobile': 'Mobile',
  'navigation_bar.app_settings': 'App settings',
  'getting_started.onboarding': 'Show me around',
  'onboarding.page_one.federation': '{domain} is an \'instance\' of Mastodon. Mastodon is a network of independent servers joining up to make one larger social network. We call these servers instances.',
  'onboarding.page_one.welcome': 'Welcome to {domain}!',
  'onboarding.page_six.github': '{domain} runs on Glitchsoc. Glitchsoc is a friendly {fork} of {Mastodon}, and is compatible with any Mastodon instance or app. Glitchsoc is entirely free and open-source. You can report bugs, request features, or contribute to the code on {github}.',
  'settings.auto_collapse': 'Automatic collapsing',
  'settings.auto_collapse_all': 'Everything',
  'settings.auto_collapse_lengthy': 'Lengthy toots',
  'settings.auto_collapse_media': 'Toots with media',
  'settings.auto_collapse_notifications': 'Notifications',
  'settings.auto_collapse_reblogs': 'Boosts',
  'settings.auto_collapse_replies': 'Replies',
  'settings.show_action_bar': 'Show action buttons in collapsed toots',
  'settings.close': 'Close',
  'settings.collapsed_statuses': 'Collapsed toots',
  'settings.enable_collapsed': 'Enable collapsed toots',
  'settings.general': 'General',
  'settings.image_backgrounds': 'Image backgrounds',
  'settings.image_backgrounds_media': 'Preview collapsed toot media',
  'settings.image_backgrounds_users': 'Give collapsed toots an image background',
  'settings.media': 'Media',
  'settings.media_letterbox': 'Letterbox media',
  'settings.media_fullwidth': 'Full-width media previews',
  'settings.preferences': 'User preferences',
  'settings.wide_view': 'Wide view (Desktop mode only)',
  'settings.navbar_under': 'Navbar at the bottom (Mobile only)',
  'status.collapse': 'Collapse',
  'status.uncollapse': 'Uncollapse',

  'media_gallery.sensitive': 'Sensitive',

  'favourite_modal.combo': 'You can press {combo} to skip this next time',

  'home.column_settings.show_direct': 'Show DMs',

  'notification.markForDeletion': 'Mark for deletion',
  'notifications.clear': 'Clear all my notifications',
  'notifications.marked_clear_confirmation': 'Are you sure you want to permanently clear all selected notifications?',
  'notifications.marked_clear': 'Clear selected notifications',

  'notification_purge.btn_all': 'Select\nall',
  'notification_purge.btn_none': 'Select\nnone',
  'notification_purge.btn_invert': 'Invert\nselection',
  'notification_purge.btn_apply': 'Clear\nselected',

  'compose.attach.upload': 'Upload a file',
  'compose.attach.doodle': 'Draw something',
  'compose.attach': 'Attach...',

  'advanced_options.local-only.short': 'Local-only',
  'advanced_options.local-only.long': 'Do not post to other instances',
  'advanced_options.local-only.tooltip': 'This post is local-only',
  'advanced_options.icon_title': 'Advanced options',
  'advanced_options.threaded_mode.short': 'Threaded mode',
  'advanced_options.threaded_mode.long': 'Automatically opens a reply on posting',
  'advanced_options.threaded_mode.tooltip': 'Threaded mode enabled',
};

export default Object.assign({}, inherited, messages);
