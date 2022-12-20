import inherited from 'mastodon/locales/uk.json';



const messages = {
  'getting_started.open_source_notice': 'Glitchsoc — вільна та відкрита модифікація {Mastodon}. Ви можете зробити свій внесок у проєкт або повідомити про вади на нашому {github}.',
  'layout.auto': 'Автоматичний',
  'layout.current_is': 'Ваш тип інтерфейсу зараз:',
  'layout.desktop': 'Настільний',
  'layout.mobile': 'Мобільний',
  'navigation_bar.app_settings': 'Налаштування програми',
  'getting_started.onboarding': 'Шо тут',
  
  'onboarding.page_one.federation': '{domain} є сервером of Mastodon. Mastodon — мережа незалежних серверів, які працюють разом великою соціяльною мережою. Сервери Mastodon також називають „інстансами“.',
  'onboarding.page_one.welcome': 'Ласкаво просимо до {domain}!',
  'onboarding.page_six.github': '{domain} використовує Glitchsoc. Glitchsoc — дружній {fork} {Mastodon}, сумісний з будь-яким сервером Mastodon або програмою для нього. Glitchsoc повністю вільний та відкритий. Повідомляти про баги, просити фічі, або працювати з кодом можна на {github}.',
  'settings.auto_collapse': 'Автоматичне згортання',
  'settings.auto_collapse_all': 'Все',
  'settings.auto_collapse_lengthy': 'Довгі дмухи',
  'settings.auto_collapse_media': 'Дмухи з медіафайлами',
  'settings.auto_collapse_notifications': 'Сповіщення',
  'settings.auto_collapse_reblogs': 'Передмухи',
  'settings.auto_collapse_replies': 'Відповіді',
  'settings.show_action_bar': 'Показувати кнопки у згорнутих дмухах',
  'settings.close': 'Закрити',
  'settings.collapsed_statuses': 'Згорнуті дмухи',
  'settings.enable_collapsed': 'Увімкути згорнутання дмухів',
  'settings.general': 'Основне',
  'settings.image_backgrounds': 'Картинки на тлі',
  'settings.image_backgrounds_media': 'Підглядати медіа зі схованих дмухів',
  'settings.image_backgrounds_users': 'Давати схованим дмухам тло-картинку',
  'settings.media': 'Медіа',
  'settings.media_letterbox': 'Обрізати медіа',
  'settings.media_fullwidth': 'Показувати медіа повною шириною',
  'settings.preferences': 'Користувацькі налаштування',
  'settings.wide_view': "Широкий вид (тільки в режимі для комп'ютерів)",
  'settings.navbar_under': 'Панель навігації знизу (тільки в режимі для мобілок)',
  'status.collapse': 'Згорнути',
  'status.uncollapse': 'Розгорнути',

  'media_gallery.sensitive': 'Чутливі',

  'favourite_modal.combo': 'Ви можете натиснути {combo}, щоб пропустити це наступного разу',

  'home.column_settings.show_direct': 'Показати прямі повідомлення',

  'notification.markForDeletion': 'Позначити для видалення',
  'notifications.clear': 'Очистити всі мої сповіщення',
  'notifications.marked_clear_confirmation': 'Ви впевнені, що хочете незворотньо очистити всі вибрані сповіщення?',
  'notifications.marked_clear': 'Очистити вибрані сповіщення',
  
  'notification_purge.btn_all': 'Вибрати\nвсе',
  'notification_purge.btn_none': 'Вибрати\nнічого',
  'notification_purge.btn_invert': 'Інвертувати\nвибір',
  'notification_purge.btn_apply': 'Очистити\nвибір',

  'compose.attach.upload': 'Завантажити сюди файл',
  'compose.attach.doodle': 'Помалювати',
  'compose.attach': 'Вкласти...',

  'advanced_options.local-only.short': 'Лише локальне',
  'advanced_options.local-only.long': 'Не дмухати це на інші сервери',
  'advanced_options.local-only.tooltip': 'Цей дмух лише локальний',
  
  // TODO: я не знаю що це значить
  //'advanced_options.icon_title': 'Advanced options',
  //'advanced_options.threaded_mode.short': 'Threaded mode',
  //'advanced_options.threaded_mode.long': 'Automatically opens a reply on posting',
  //'advanced_options.threaded_mode.tooltip': 'Threaded mode enabled',
};

export default Object.assign({}, inherited, messages);
