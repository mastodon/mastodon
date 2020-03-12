require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddTitleToAccountWarningPresets < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :account_warning_presets, :title, :string, default: '', allow_null: false }
  end

  def down
    remove_column :account_warning_presets, :title
  end
end
