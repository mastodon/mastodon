require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddDisabledToUsers < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :users, :disabled, :bool, default: false }
  end

  def down
    remove_column :users, :disabled
  end
end
