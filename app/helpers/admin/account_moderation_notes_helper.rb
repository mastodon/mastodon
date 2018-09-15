# frozen_string_literal: true

module Admin::AccountModerationNotesHelper
  def admin_account_link_to(account)
    return if account.nil?

    link_to admin_account_path(account.id), class: name_tag_classes(account), title: account.acct do
      safe_join([
                  image_tag(account.avatar.url, width: 15, height: 15, alt: display_name(account), class: 'avatar'),
                  content_tag(:span, account.acct, class: 'username'),
                ], ' ')
    end
  end

  def admin_account_inline_link_to(account)
    return if account.nil?

    link_to admin_account_path(account.id), class: name_tag_classes(account, true), title: account.acct do
      content_tag(:span, account.acct, class: 'username')
    end
  end

  private

  def name_tag_classes(account, inline = false)
    classes = [inline ? 'inline-name-tag' : 'name-tag']
    classes << 'suspended' if account.suspended?
    classes.join(' ')
  end
end
