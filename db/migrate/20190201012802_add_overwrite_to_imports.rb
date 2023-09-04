require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddOverwriteToImports < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :imports, :overwrite, :boolean, default: false, allow_null: false
    end
  end

  def down
    remove_column :imports, :overwrite, :boolean
  end
end
