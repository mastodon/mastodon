require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddSilentToMentions < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default(
        :mentions,
        :silent,
        :boolean,
        allow_null: false,
        default: false
      )
    end
  end

  def down
    remove_column :mentions, :silent
  end
end
