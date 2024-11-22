# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :accounts do |t|
      t.string :username, null: false, default: ''
      t.string :domain, null: true

      # PuSH credentials
      t.string :verify_token, null: false, default: ''
      t.string :secret, null: false, default: ''

      # RSA key pair
      t.text :private_key, null: true
      t.text :public_key, null: false, default: ''

      # URLs
      t.string :remote_url, null: false, default: ''
      t.string :salmon_url, null: false, default: ''
      t.string :hub_url, null: false, default: ''

      t.timestamps null: false
    end

    add_index :accounts, [:username, :domain], unique: true
  end
end
