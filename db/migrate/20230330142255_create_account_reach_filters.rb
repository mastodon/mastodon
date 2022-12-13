# frozen_string_literal: true

class CreateAccountReachFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :account_reach_filters do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :salt, null: false
      t.binary :bloom_filter

      t.timestamps
    end
  end
end
