# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
    eo: 'Esperanto',
    fr: 'Français',
    hu: 'Magyar',
    no: 'Norsk',
    pt: 'Português',
    fi: 'Suomi',
    ru: 'Русский',
    uk: 'Українська',
    ja: '日本語',
    'zh-CN': '简体中文',
    'zh-HK': '繁體中文（香港）',
  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end

  def hash_to_object(hash)
    HashObject.new(hash)
  end
end
