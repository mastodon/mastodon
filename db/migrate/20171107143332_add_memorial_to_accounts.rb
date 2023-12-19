# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddMemorialToAccounts < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :accounts, :memorial, :bool, default: false }
  end

  def down
    remove_column :accounts, :memorial
  end
end
