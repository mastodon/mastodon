# frozen_string_literal: true

class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.belongs_to :account, foreign_key: { on_delete: :cascade }
      t.belongs_to :status, foreign_key: { on_delete: :cascade }
      t.datetime :expires_at
      t.string :options, null: false, array: true, default: []
      t.bigint :cached_tallies, null: false, array: true, default: []
      t.boolean :multiple, null: false, default: false
      t.boolean :hide_totals, null: false, default: false
      t.bigint :votes_count, null: false, default: 0
      t.datetime :last_fetched_at

      t.timestamps
    end
  end
end
