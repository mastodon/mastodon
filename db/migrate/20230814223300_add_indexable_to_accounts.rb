# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddIndexableToAccounts < ActiveRecord::Migration[7.0]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :accounts, :indexable, :boolean, default: false, allow_null: false }
  end

  def down
    remove_column :accounts, :indexable
  end
end
