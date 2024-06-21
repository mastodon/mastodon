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

    change_table :users, bulk: true do |t|
      t.remove :encrypted_password
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_at
      t.remove :last_sign_in_ip
    end
  end
end
