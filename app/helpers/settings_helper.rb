# frozen_string_literal: true

module SettingsHelper
  def filterable_languages
    LanguagesHelper::SUPPORTED_LOCALES.keys
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

  def compact_account_link_to(account)
    return if account.nil?

    link_to ActivityPub::TagManager.instance.url_for(account), class: 'name-tag', title: account.acct do
      safe_join([image_tag(account.avatar.url, width: 15, height: 15, alt: display_name(account), class: 'avatar'), content_tag(:span, account.acct, class: 'username')], ' ')
    end
  end

  def picture_hint(hint, picture)
    if picture.original_filename.nil?
      hint
    else
      link = link_to t('generic.delete'), settings_profile_picture_path(picture.name.to_s), data: { method: :delete }
      safe_join([hint, link], '<br/>'.html_safe)
    end
  end
end
