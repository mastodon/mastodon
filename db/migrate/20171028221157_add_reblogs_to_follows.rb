require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddReblogsToFollows < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default :follows, :show_reblogs, :boolean, default: true, allow_null: false
      add_column_with_default :follow_requests, :show_reblogs, :boolean, default: true, allow_null: false
    end
  end

  def down
    remove_column :follows, :show_reblogs
    remove_column :follow_requests, :show_reblogs
  end
end
