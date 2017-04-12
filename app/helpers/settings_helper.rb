# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
    eo: 'Esperanto',
    fr: 'Français',
    hu: 'Magyar',
    pt: 'Português',
    fi: 'Suomi',
    ru: '�уѺий',
    uk: 'Українька',
    ja: '日本�,
    'zh-CN': '简体中�,
    'zh-HK': '繫�中於�香港,
  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end

  def hash_to_object(hash)
    HashObject.new(hash)
  end
end
