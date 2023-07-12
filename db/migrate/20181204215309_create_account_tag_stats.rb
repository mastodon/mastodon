# frozen_string_literal: true

class CreateAccountTagStats < ActiveRecord::Migration[5.2]
  def change
    create_table :account_tag_stats do |t|
      t.belongs_to :tag, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.bigint :accounts_count, default: 0, null: false
      t.boolean :hidden, default: false, null: false

      t.timestamps
    end
  end
end
