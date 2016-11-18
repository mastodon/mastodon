# frozen_string_literal: true

module SettingsHelper
  HUMAN_LOCALES = {
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
  }.freeze

  def human_locale(locale)
    HUMAN_LOCALES[locale]
  end
end
