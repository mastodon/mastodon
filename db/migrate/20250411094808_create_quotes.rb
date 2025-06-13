# frozen_string_literal: true

class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }, index: false, null: false
      t.belongs_to :status, foreign_key: { on_delete: :cascade }, index: { unique: true }, null: false
      t.belongs_to :quoted_status, foreign_key: { to_table: :statuses, on_delete: :nullify }, null: true
      t.belongs_to :quoted_account, foreign_key: { to_table: :accounts, on_delete: :nullify }, null: true
      t.integer :state, null: false, default: 0
      t.string :approval_uri, index: { where: 'approval_uri IS NOT NULL' }
      t.string :activity_uri, index: { unique: true, where: 'activity_uri IS NOT NULL' }

      t.timestamps
    end

    # Can be used in the future to e.g. bulk-reject quotes from blocked accounts
    add_index :quotes, [:account_id, :quoted_account_id]
  end
end
