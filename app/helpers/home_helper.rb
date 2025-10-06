# frozen_string_literal: true

module HomeHelper
  def default_props
    {
      locale: I18n.locale,
    }
  end

  def account_link_to(account, button = '', path: nil)
    content_tag(:div, class: 'account account--minimal') do
      content_tag(:div, class: 'account__wrapper') do
        section = if account.nil?
                    content_tag(:div, class: 'account__display-name') do
                      content_tag(:div, class: 'account__avatar-wrapper') do
                        image_tag(full_asset_url('avatars/original/missing.png', skip_pipeline: true), class: 'account__avatar')
                      end +
                        content_tag(:span, class: 'display-name') do
                          content_tag(:strong, t('about.contact_missing')) +
                            content_tag(:span, t('about.contact_unavailable'), class: 'display-name__account')
                        end
                    end
                  else
                    account_url = if account.suspended?
                                    ActivityPub::TagManager.instance.url_for(account)
                                  else
                                    web_url("@#{account.pretty_acct}")
                                  end

                    link_to(path || account_url, class: 'account__display-name') do
                      content_tag(:div, class: 'account__avatar-wrapper') do
                        image_tag(full_asset_url(current_account&.user&.setting_auto_play_gif ? account.avatar_original_url : account.avatar_static_url), class: 'account__avatar', width: 46, height: 46)
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

  def field_verified_class(verified)
    if verified
      'verified'
    else
      'emojify'
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
