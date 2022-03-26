# frozen_string_literal: true

module AccountsHelper
  def display_name(account, **options)
    str = account.display_name.presence || account.username

    if options[:custom_emojify]
      prerender_custom_emojis(h(str), account.emojis)
    else
      str
    end
  end

  def acct(account)
    if account.local?
      "@#{account.acct}@#{site_hostname}"
    else
      "@#{account.pretty_acct}"
    end
  end

  def account_action_button(account)
    if user_signed_in?
      if account.id == current_user.account_id
        link_to settings_profile_url, class: 'button logo-button' do
          safe_join([svg_logo, t('settings.edit_profile')])
        end
      elsif current_account.following?(account) || current_account.requested?(account)
        link_to account_unfollow_path(account), class: 'button logo-button button--destructive', data: { method: :post } do
          safe_join([svg_logo, t('accounts.unfollow')])
        end
      elsif !(account.memorial? || account.moved?)
        link_to account_follow_path(account), class: "button logo-button#{account.blocking?(current_account) ? ' disabled' : ''}", data: { method: :post } do
          safe_join([svg_logo, t('accounts.follow')])
        end
      end
    elsif !(account.memorial? || account.moved?)
      link_to account_remote_follow_path(account), class: 'button logo-button modal-button', target: '_new' do
        safe_join([svg_logo, t('accounts.follow')])
      end
    end
  end

  def minimal_account_action_button(account)
    if user_signed_in?
      return if account.id == current_user.account_id

      if current_account.following?(account) || current_account.requested?(account)
        link_to account_unfollow_path(account), class: 'icon-button active', data: { method: :post }, title: t('accounts.unfollow') do
          fa_icon('user-times fw')
        end
      elsif !(account.memorial? || account.moved?)
        link_to account_follow_path(account), class: "icon-button#{account.blocking?(current_account) ? ' disabled' : ''}", data: { method: :post }, title: t('accounts.follow') do
          fa_icon('user-plus fw')
        end
      end
    elsif !(account.memorial? || account.moved?)
      link_to account_remote_follow_path(account), class: 'icon-button modal-button', target: '_new', title: t('accounts.follow') do
        fa_icon('user-plus fw')
      end
    end
  end

  def account_badge(account, all: false)
    if account.bot?
      content_tag(:div, content_tag(:div, t('accounts.roles.bot'), class: 'account-role bot'), class: 'roles')
    elsif account.group?
      content_tag(:div, content_tag(:div, t('accounts.roles.group'), class: 'account-role group'), class: 'roles')
    elsif (Setting.show_staff_badge && account.user_staff?) || all
      content_tag(:div, class: 'roles') do
        if all && !account.user_staff?
          content_tag(:div, t('admin.accounts.roles.user'), class: 'account-role')
        elsif account.user_admin?
          content_tag(:div, t('accounts.roles.admin'), class: 'account-role admin')
        elsif account.user_moderator?
          content_tag(:div, t('accounts.roles.moderator'), class: 'account-role moderator')
        end
      end
    end
  end

  def hide_followers_count?(account)
    Setting.hide_followers_count || account.user&.setting_hide_followers_count
  end

  def account_description(account)
    prepend_stats = [
      [
        number_to_human(account.statuses_count, precision: 3, strip_insignificant_zeros: true),
        I18n.t('accounts.posts', count: account.statuses_count),
      ].join(' '),

      [
        number_to_human(account.following_count, precision: 3, strip_insignificant_zeros: true),
        I18n.t('accounts.following', count: account.following_count),
      ].join(' '),
    ]

    unless hide_followers_count?(account)
      prepend_stats << [
        number_to_human(account.followers_count, precision: 3, strip_insignificant_zeros: true),
        I18n.t('accounts.followers', count: account.followers_count),
      ].join(' ')
    end

    [prepend_stats.join(', '), account.note].join(' · ')
  end

  def svg_logo
    content_tag(:svg, tag(:use, 'xlink:href' => '#mastodon-svg-logo'), 'viewBox' => '0 0 216.4144 232.00976')
  end

  def svg_logo_full
    content_tag(:svg, tag(:use, 'xlink:href' => '#mastodon-svg-logo-full'), 'viewBox' => '0 0 713.35878 175.8678')
  end
end
