# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[4.2]
  def up
    change_table(:users, bulk: true) do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip
    end

    add_index :users, :reset_password_token, unique: true
  end

  def down
    remove_index :users, :reset_password_token

    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_at
    remove_column :users, :last_sign_in_ip
  end
end
