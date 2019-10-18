# frozen_string_literal: true

module HomeHelper
  def default_props
    {
      locale: I18n.locale,
    }
  end

  def account_link_to(account, button = '', size: 36, path: nil)
    content_tag(:div, class: 'account') do
      content_tag(:div, class: 'account__wrapper') do
        section = if account.nil?
                    content_tag(:div, class: 'account__display-name') do
                      content_tag(:div, class: 'account__avatar-wrapper') do
                        content_tag(:div, '', class: 'account__avatar', style: "width: #{size}px; height: #{size}px; background-size: #{size}px #{size}px; background-image: url(#{full_asset_url('avatars/original/missing.png', skip_pipeline: true)})")
                      end +
                        content_tag(:span, class: 'display-name') do
                          content_tag(:strong, t('about.contact_missing')) +
                            content_tag(:span, t('about.contact_unavailable'), class: 'display-name__account')
                        end
                    end
                  else
                    link_to(path || ActivityPub::TagManager.instance.url_for(account), class: 'account__display-name') do
                      content_tag(:div, class: 'account__avatar-wrapper') do
                        content_tag(:div, '', class: 'account__avatar', style: "width: #{size}px; height: #{size}px; background-size: #{size}px #{size}px; background-image: url(#{full_asset_url(current_account&.user&.setting_auto_play_gif ? account.avatar_original_url : account.avatar_static_url)})")
                      end +
                        content_tag(:span, class: 'display-name') do
                          content_tag(:bdi) do
                            content_tag(:strong, display_name(account, custom_emojify: true), class: 'display-name__html emojify')
                          end +
                            content_tag(:span, "@#{account.acct}", class: 'display-name__account')
                        end
                    end
                  end

        section + button
      end
    end
  end

  def obscured_counter(count)
    if count <= 0
      0
    elsif count == 1
      1
    else
      '1+'
    end
  end

  def custom_field_classes(field)
    if field.verified?
      'verified'
    else
      'emojify'
    end
  end

  def optional_link_to(condition, path, options = {}, &block)
    if condition
      link_to(path, options, &block)
    else
      content_tag(:div, &block)
    end
  end

  def sign_up_message
    if closed_registrations?
      t('auth.registration_closed', instance: site_hostname)
    elsif open_registrations?
      t('auth.register')
    elsif approved_registrations?
      t('auth.apply_for_account')
    end
  end
end
