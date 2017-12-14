require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddSensitiveToDomainBlock < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :domain_blocks, :sensitive, :boolean, default: false, allow_null: false
    end
  end

  def down
    remove_column :domain_blocks, :sensitive
  end
end
