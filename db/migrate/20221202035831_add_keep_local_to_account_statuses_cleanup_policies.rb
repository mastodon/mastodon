class AddKeepLocalToAccountStatusesCleanupPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :account_statuses_cleanup_policies, :keep_local, :boolean
    change_column_default :account_statuses_cleanup_policies, :keep_local, false
  end
end
