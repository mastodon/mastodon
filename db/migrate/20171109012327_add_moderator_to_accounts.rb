# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddModeratorToAccounts < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :users, :moderator, :bool, default: false }
  end

  def down
    remove_column :users, :moderator
  end
end
