# frozen_string_literal: true

module SettingsHelper
  def themes_select_collection
    # Rails form helpers get HTML options for inputs from the collections whose items are
    # themselves arrays including a hash: https://github.com/rails/rails/blob/41b352dcf23e28b38c67dcd4fe341bac0d52334c/actionview/lib/action_view/helpers/form_options_helper.rb#L807-L813
    # Since we have to do this to pass options, also pass the label in the collection itself.
    Themes.instance.names.map do |theme|
      [
        I18n.t("themes.#{theme}", default: theme),
        theme,
        {
          data: {
            colors: available_theme_colors(theme).index_with { |color| I18n.t("color_theme.#{color}", default: color) }.to_json,
          },
        },
      ]
    end
  end

  def filterable_languages
    LanguagesHelper.sorted_locale_keys(LanguagesHelper::SUPPORTED_LOCALES.keys)
  end

  def ui_languages
    LanguagesHelper.sorted_locale_keys(I18n.available_locales)
  end

  def inline_qrcode_svg(code)
    code
      .as_svg(padding: 0, module_size: 4, use_path: true)
      .html_safe # rubocop:disable Rails/OutputSafety
  end

  def user_settings_collection(value)
    UserSettings.definition_for(value)&.in || []
  end

  def author_attribution_name(account)
    return if account.nil?

    link_to(root_url, class: 'story__details__shared__author-link') do
      safe_join(
        [image_tag(account.avatar.url, class: 'account__avatar', size: 16, alt: ''), tag.bdi(display_name(account))]
      )
    end
  end

  def session_device_icon(session)
    device = session.detection.device

    if device.mobile?
      'smartphone'
    elsif device.tablet?
      'tablet'
    else
      'desktop_mac'
    end
  end

  def compact_account_link_to(account)
    return if account.nil?

    link_to ActivityPub::TagManager.instance.url_for(account), class: 'name-tag', title: account.acct do
      safe_join([image_tag(account.avatar.url, width: 15, height: 15, alt: '', class: 'avatar'), content_tag(:span, account.acct, class: 'username')], ' ')
    end
  end

  def time_zone_options
    ActiveSupport::TimeZone.all.map { |tz| ["(GMT#{tz.now.formatted_offset}) #{tz.name}", tz.tzinfo.name] }
  end
end
