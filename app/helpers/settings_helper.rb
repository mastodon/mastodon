# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
    eo: 'Esperanto',
    pt: 'Português',
    fr: 'Français',
    hu: 'Magyar',
    uk: 'Українська',
    'zh-CN': '简体中文',
    fi: 'Suomi',
    ru: 'Русский',
    ja: '日本語',

  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end

  def hash_to_object(hash)
    HashObject.new(hash)
  end
end
