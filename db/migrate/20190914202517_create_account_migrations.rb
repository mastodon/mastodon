# frozen_string_literal: true

class CreateAccountMigrations < ActiveRecord::Migration[5.2]
  def change
    create_table :account_migrations do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.string :acct, null: false, default: ''
      t.bigint :followers_count, null: false, default: 0
      t.belongs_to :target_account, foreign_key: { to_table: :accounts, on_delete: :nullify }

      t.timestamps
    end
  end
end
