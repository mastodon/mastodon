# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddExclusiveToLists < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :lists, :exclusive, :boolean, default: false, allow_null: false }
  end

  def down
    remove_column :lists, :exclusive
  end
end
