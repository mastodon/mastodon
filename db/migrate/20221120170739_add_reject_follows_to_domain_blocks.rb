require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddRejectFollowsToDomainBlocks < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :domain_blocks, :reject_follows, :boolean, default: false, allow_null: false
    end
  end

  def down
    remove_column :domain_blocks, :reject_follows
  end
end
