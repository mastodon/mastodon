# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    ar: 'العربية',
    ast: 'l\'asturianu',
    bg: 'Български',
    ca: 'Català',
    co: 'Corsu',
    da: 'Dansk',
    de: 'Deutsch',
    el: 'Ελληνικά',
    eo: 'Esperanto',
    es: 'Español',
    eu: 'Euskara',
    fa: 'فارسی',
    fi: 'Suomi',
    fr: 'Français',
    gl: 'Galego',
    he: 'עברית',
    hr: 'Hrvatski',
    hu: 'Magyar',
    hy: 'Հայերեն',
    id: 'Bahasa Indonesia',
    io: 'Ido',
    it: 'Italiano',
    ja: '日本語',
    ko: '한국어',
    nl: 'Nederlands',
    no: 'Norsk',
    oc: 'Occitan',
    pl: 'Polszczyzna',
    pt: 'Português',
    'pt-BR': 'Português do Brasil',
    ru: 'Русский',
    sk: 'Slovensky',
    sl: 'Slovenščina',
    sr: 'Српски',
    'sr-Latn': 'Srpski (latinica)',
    sv: 'Svenska',
    te: 'తెలుగు',
    th: 'ภาษาไทย',
    tr: 'Türkçe',
    uk: 'Українська',
    zh: '中文',
    'zh-CN': '简体中文',
    'zh-HK': '繁體中文（香港）',
    'zh-TW': '繁體中文（臺灣）',
  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end

  def filterable_languages
    LanguageDetector.instance.language_names.select(&HUMAN_LOCALES.method(:key?))
  end

  def hash_to_object(hash)
    HashObject.new(hash)
  end

  def session_device_icon(session)
    device = session.detection.device

    if device.mobile?
      'mobile'
    elsif device.tablet?
      'tablet'
    else
      'desktop'
    end
  end
end
