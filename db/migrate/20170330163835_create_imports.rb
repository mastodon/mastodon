# frozen_string_literal: true

class CreateImports < ActiveRecord::Migration[5.0]
  def change
    create_table :imports do |t|
      t.integer :account_id, null: false
      t.integer :type, null: false
      t.boolean :approved # rubocop:disable Rails/ThreeStateBooleanColumn

      t.timestamps
    end
  end
end
