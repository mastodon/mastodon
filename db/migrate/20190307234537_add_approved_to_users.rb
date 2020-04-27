require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddApprovedToUsers < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default(
        :users,
        :approved,
        :bool,
        allow_null: false,
        default: true
      )
    end
  end

  def down
    remove_column :users, :approved
  end
end
