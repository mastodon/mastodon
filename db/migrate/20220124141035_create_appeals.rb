# frozen_string_literal: true

class CreateAppeals < ActiveRecord::Migration[6.1]
  def change
    create_table :appeals do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :account_warning, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.text :text, null: false, default: ''
      t.datetime :approved_at
      t.belongs_to :approved_by_account, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.datetime :rejected_at
      t.belongs_to :rejected_by_account, foreign_key: { to_table: :accounts, on_delete: :nullify }
      t.timestamps
    end
  end
end
