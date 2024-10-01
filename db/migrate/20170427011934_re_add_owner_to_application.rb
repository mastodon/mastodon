# frozen_string_literal: true

class ReAddOwnerToApplication < ActiveRecord::Migration[5.0]
  def change
    change_table(:oauth_applications, bulk: true) do |t|
      t.column :owner_id, :integer, null: true
      t.column :owner_type, :string, null: true
    end
    add_index :oauth_applications, [:owner_id, :owner_type]
    add_foreign_key :oauth_applications, :users, column: :owner_id, on_delete: :cascade
  end
end
