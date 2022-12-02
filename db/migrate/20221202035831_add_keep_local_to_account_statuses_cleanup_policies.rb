class AddKeepLocalToAccountStatusesCleanupPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :account_statuses_cleanup_policies, :keep_local, :boolean, null: false, default: true
  end
end
