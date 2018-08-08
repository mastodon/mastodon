# frozen_string_literal: true

module HomeHelper
  def default_props
    {
      locale: I18n.locale,
    }
  end

  def account_link_to(account, button = '')
    content_tag(:div, class: 'account') do
      content_tag(:div, class: 'account__wrapper') do
        section = if account.nil?
                    content_tag(:div, class: 'account__display-name') do
                      content_tag(:div, class: 'account__avatar-wrapper') do
                        content_tag(:div, '', class: 'account__avatar', style: "background-image: url(#{full_asset_url('avatars/original/missing.png', skip_pipeline: true)})")
                      end +
                        content_tag(:span, class: 'display-name') do
                          content_tag(:strong, t('about.contact_missing')) +
                            content_tag(:span, t('about.contact_unavailable'), class: 'display-name__account')
                        end
                    end
                  else
                    link_to(TagManager.instance.url_for(account), class: 'account__display-name') do
                      content_tag(:div, class: 'account__avatar-wrapper') do
                        content_tag(:div, '', class: 'account__avatar', style: "background-image: url(#{account.avatar.url})")
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
end
