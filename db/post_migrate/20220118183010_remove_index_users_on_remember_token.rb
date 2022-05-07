# frozen_string_literal: true

class RemoveIndexUsersOnRememberToken < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    remove_index :users, name: :index_users_on_remember_token
  end

  def down
    add_index :users, :remember_token, algorithm: :concurrently, unique: true, name: :index_users_on_remember_token
  end
end
