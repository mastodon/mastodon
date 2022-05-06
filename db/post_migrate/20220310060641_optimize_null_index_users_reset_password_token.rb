# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class OptimizeNullIndexUsersResetPasswordToken < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    update_index :users, 'index_users_on_reset_password_token', :reset_password_token, unique: true, where: 'reset_password_token IS NOT NULL', opclass: :text_pattern_ops
  end

  def down
    update_index :users, 'index_users_on_reset_password_token', :reset_password_token, unique: true
  end
end
