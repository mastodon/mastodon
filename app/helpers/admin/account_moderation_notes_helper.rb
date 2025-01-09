# frozen_string_literal: true

module Admin::AccountModerationNotesHelper
  def admin_account_link_to(account, path: nil)
    return if account.nil?

    link_to(
      labeled_account_avatar(account),
      path || admin_account_path(account.id),
      class: class_names('name-tag', suspended: suspended_account?(account)),
      title: account.acct
    )
  end

  def admin_account_inline_link_to(account, path: nil)
    return if account.nil?

    link_to(
      account_inline_text(account),
      path || admin_account_path(account.id),
      class: class_names('inline-name-tag', suspended: suspended_account?(account)),
      title: account.acct
    )
  end

  private

  def labeled_account_avatar(account)
    safe_join(
      [
        image_tag(account.avatar.url, width: 15, height: 15, alt: '', class: 'avatar'),
        account_inline_text(account),
      ],
      ' '
    )
  end

  def account_inline_text(account)
    content_tag(:span, account.acct, class: 'username')
  end

  def suspended_account?(account)
    account.suspended? || (account.local? && account.user.nil?)
  end
end
