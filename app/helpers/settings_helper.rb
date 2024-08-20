# frozen_string_literal: true

module SettingsHelper
  def filterable_languages
    LanguagesHelper.sorted_locale_keys(LanguagesHelper::SUPPORTED_LOCALES.keys)
  end

  def ui_languages
    LanguagesHelper.sorted_locale_keys(I18n.available_locales)
  end

  def featured_tags_hint(recently_used_tags)
    safe_join(
      [
        t('simple_form.hints.featured_tag.name'),
        safe_join(
          links_for_featured_tags(recently_used_tags),
          ', '
        ),
      ],
      ' '
    )
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

  private

  def links_for_featured_tags(tags)
    tags.map { |tag| post_link_to_featured_tag(tag) }
  end

  def post_link_to_featured_tag(tag)
    link_to(
      "##{tag.display_name}",
      settings_featured_tags_path(featured_tag: { name: tag.name }),
      method: :post
    )
  end
end
