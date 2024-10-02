# frozen_string_literal: true

module Admin::AccountsHelper
  def admin_accounts_moderation_options
    [
      [t('admin.accounts.moderation.active'), 'active'],
      [t('admin.accounts.moderation.silenced'), 'silenced'],
      [t('admin.accounts.moderation.disabled'), 'disabled'],
      [t('admin.accounts.moderation.suspended'), 'suspended'],
      [safe_join([t('admin.accounts.moderation.pending'), "(#{pending_user_count_label})"], ' '), 'pending'],
    ]
  end

  def remote_suspension_hint(deletion_request)
    if deletion_request.present?
      t('admin.accounts.remote_suspension_reversible_hint_html', date: due_date_for_hint(deletion_request))
    else
      t('admin.accounts.remote_suspension_irreversible')
    end
  end

  def suspension_hint(deletion_request)
    if deletion_request.present?
      t('admin.accounts.suspension_reversible_hint_html', date: due_date_for_hint(deletion_request))
    else
      t('admin.accounts.suspension_irreversible')
    end
  end

  private

  def due_date_for_hint(deletion_request)
    tag.strong(l(deletion_request.due_at.to_date))
  end

  def pending_user_count_label
    number_with_delimiter User.pending.count
  end
end
