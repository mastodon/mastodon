# frozen_string_literal: true

class CreateTombstones < ActiveRecord::Migration[5.2]
  def change
    create_table :tombstones do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.string :uri, null: false

      t.timestamps
    end

    add_index :tombstones, :uri
  end
end
