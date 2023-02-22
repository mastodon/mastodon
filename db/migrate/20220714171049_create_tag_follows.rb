# frozen_string_literal: true

class CreateTagFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :tag_follows do |t|
      t.belongs_to :tag, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.timestamps
    end

    add_index :tag_follows, [:account_id, :tag_id], unique: true
  end
end
