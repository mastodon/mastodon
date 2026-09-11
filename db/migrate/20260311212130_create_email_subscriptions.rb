# frozen_string_literal: true

class CreateEmailSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :email_subscriptions do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :email, null: false
      t.string :locale, null: false
      t.string :confirmation_token, index: { unique: true, where: 'confirmation_token is not null' }
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :email_subscriptions, [:account_id, :email], unique: true
  end
end
