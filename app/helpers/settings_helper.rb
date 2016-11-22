# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
    fr: 'Français',
  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end
end
