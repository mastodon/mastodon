require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddShowBlockedUsersToAccounts < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :accounts,
        :show_blocked_users,
        :bool
      )
    end
  end

  def down
    remove_column :accounts, :show_blocked_users
  end
end
