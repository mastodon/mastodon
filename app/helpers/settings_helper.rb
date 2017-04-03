# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
    pt: 'Português',
    fr: 'Français',
    hu: 'Magyar',
    uk: 'Українська',
    'zh-CN': '简体中文',
    eo: 'Esperanto',
  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end

  def hash_to_object(hash)
    HashObject.new(hash)
  end
end
