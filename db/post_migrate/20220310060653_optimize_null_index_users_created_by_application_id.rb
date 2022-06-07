# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexUsersCreatedByApplicationId < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :users, 'index_users_on_created_by_application_id', :created_by_application_id, where: 'created_by_application_id IS NOT NULL'
  end

  def down
    update_index :users, 'index_users_on_created_by_application_id', :created_by_application_id
  end
end
