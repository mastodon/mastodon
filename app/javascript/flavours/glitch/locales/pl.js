import inherited from 'mastodon/locales/pl.json';

const messages = {
  'getting_started.open_source_notice': 'Glitchsoc jest wolnym i otwartoźródłowym forkiem oprogramowania {Mastodon}. Możesz współtworzyć projekt lub zgłaszać błędy na GitHubie pod adresem {github}.',
  'layout.auto': 'Automatyczny',
  'layout.current_is': 'Twój obecny układ to:',
  'layout.desktop': 'Desktopowy',
  'layout.mobile': 'Mobilny',
  'navigation_bar.app_settings': 'Ustawienia aplikacji',
  'navigation_bar.bookmarks': 'Zakładki',
  'getting_started.onboarding': 'Rozejrzyj się',
  'onboarding.page_one.federation': '{domain} jest \'instancją\' Mastodona. Mastodon to sieć działających niezależnie serwerów tworzących jedną sieć społecznościową. Te serwery nazywane są instancjami.',
  'onboarding.page_one.welcome': 'Witamy na {domain}!',
  'onboarding.page_six.github': '{domain} jest oparty na Glitchsoc. Glitchsoc jest {forkiem} {Mastodon}a kompatybilnym z każdym klientem i aplikacją Mastodona. Glitchsoc jest całkowicie wolnym i otwartoźródłowym oprogramowaniem. Możesz zgłaszać błędy i sugestie funkcji oraz współtworzyć projekt na {github}.',
  'settings.auto_collapse': 'Automatyczne zwijanie',
  'settings.auto_collapse_all': 'Wszystko',
  'settings.auto_collapse_lengthy': 'Długie wpisy',
  'settings.auto_collapse_media': 'Wpisy z zawartością multimedialną',
  'settings.auto_collapse_notifications': 'Powiadomienia',
  'settings.auto_collapse_reblogs': 'Podbicia',
  'settings.auto_collapse_replies': 'Odpowiedzi',
  'settings.close': 'Zamknij',
  'settings.collapsed_statuses': 'Zwijanie wpisów',
  'settings.enable_collapsed': 'Włącz zwijanie wpisów',
  'settings.general': 'Ogólne',
  'settings.image_backgrounds': 'Obrazy w tle',
  'settings.image_backgrounds_media': 'Wyświetlaj zawartość multimedialną zwiniętych wpisów',
  'settings.image_backgrounds_users': 'Nadaj tło zwiniętym wpisom',
  'settings.layout': 'Układ',
  'settings.media': 'Zawartość multimedialna',
  'settings.media_letterbox': 'Letterbox media',
  'settings.media_fullwidth': 'Podgląd zawartości multimedialnej o pełnej szerokości',
  'settings.navbar_under': 'Pasek nawigacji na dole (tylko w trybie mobilnym)',
  'settings.preferences': 'Preferencje użytkownika',
  'settings.side_arm': 'Drugi przycisk wysyłania',
  'settings.side_arm.none': 'Żaden',
  'settings.wide_view': 'Szeroki widok (tylko w trybie desktopowym)',
  'status.bookmark': 'Dodaj do zakładek',
  'status.collapse': 'Zwiń',
  'status.uncollapse': 'Rozwiń',

  'media_gallery.sensitive': 'Zawartość wrażliwa',

  'favourite_modal.combo': 'Możesz nacisnąć {combo}, aby pominąć to następnym razem',

  'home.column_settings.show_direct': 'Pokaż wiadomości bezpośrednie',

  'notification.markForDeletion': 'Oznacz do usunięcia',
  'notifications.clear': 'Wyczyść wszystkie powiadomienia',
  'notifications.marked_clear_confirmation': 'Czy na pewno chcesz bezpowrtonie usunąć wszystkie powiadomienia?',
  'notifications.marked_clear': 'Usuń zaznaczone powiadomienia',

  'notification_purge.btn_all': 'Zaznacz\nwszystkie',
  'notification_purge.btn_none': 'Odznacz\nwszystkie',
  'notification_purge.btn_invert': 'Odwróć\nzaznaczenie',
  'notification_purge.btn_apply': 'Usuń\nzaznaczone',
  'notification_purge.start': 'Przejdź do trybu usuwania powiadomień',

  'compose.attach.upload': 'Wyślij plik',
  'compose.attach.doodle': 'Narysuj coś',
  'compose.attach': 'Załącz coś',

  'advanced_options.local-only.short': 'Tylko lokalnie',
  'advanced_options.local-only.long': 'Nie wysyłaj na inne instancje',
  'advanced_options.local-only.tooltip': 'Ten wpis jest widoczny tylko lokalnie',
  'advanced_options.icon_title': 'Ustawienia zaawansowane',
  'advanced_options.threaded_mode.short': 'Tryb wątków',
  'advanced_options.threaded_mode.long': 'Przechodzi do tworzenia odpowiedzi po publikacji wpisu',
  'advanced_options.threaded_mode.tooltip': 'Włączono tryb wątków',
  
  'column.bookmarks': 'Zakładki',
  'compose_form.sensitive': 'Oznacz zawartość multimedialną jako wrażliwą',
  'compose_form.spoiler': 'Ukryj tekst za ostrzeżeniem',
  'favourite_modal.combo': 'Możesz nacisnąć {combo}, aby pominąć to następnym razem',
  'tabs_bar.compose': 'Napisz',
  
};

export default Object.assign({}, inherited, messages);
