# frozen_string_literal: true

class CreateBackups < ActiveRecord::Migration[5.2]
  def change
    create_table :backups do |t|
      t.references :user, foreign_key: { on_delete: :nullify }
      t.attachment :dump
      t.boolean :processed, null: false, default: false

      t.timestamps
    end
  end
end
