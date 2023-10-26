# frozen_string_literal: true

module Settings::PreferencesHelper
  def display_media_options
    %w(default show_all hide_all)
  end

  def display_media_label(item)
    t("simple_form.hints.defaults.setting_display_media_#{item}")
  end

  def software_updates_label(setting)
    I18n.t("simple_form.labels.notification_emails.software_updates.#{setting}")
  end

  def default_language_label(locale)
    locale.nil? ? I18n.t('statuses.default_language') : native_locale_name(locale)
  end

  def default_privacy_label(visibility)
    safe_join(
      [
        I18n.t("statuses.visibilities.#{visibility}"),
        I18n.t("statuses.visibilities.#{visibility}_long"),
      ],
      ' - '
    )
  end
end
