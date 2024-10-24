# frozen_string_literal: true

module Admin::AccountsHelper
  def admin_accounts_moderation_options(counts)
    [
      [t('admin.accounts.moderation.active'), 'active'],
      [t('admin.accounts.moderation.silenced'), 'silenced'],
      [t('admin.accounts.moderation.disabled'), 'disabled'],
      [t('admin.accounts.moderation.suspended'), 'suspended'],
      [safe_join([t('admin.accounts.moderation.pending'), "(#{number_with_delimiter(counts[:pending].value)})"], ' '), 'pending'],
    ]
  end
end
