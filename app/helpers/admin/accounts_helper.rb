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

  private

  def pending_user_count_label
    number_with_delimiter User.pending.count
  end
end
