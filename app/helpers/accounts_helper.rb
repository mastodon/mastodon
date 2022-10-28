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
    return if account.memorial? || account.moved?

    link_to ActivityPub::TagManager.instance.url_for(account), class: 'button logo-button', target: '_new' do
      safe_join([logo_as_symbol, t('accounts.follow')])
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
end
