# frozen_string_literal: true

class AddOwnerToApplication < ActiveRecord::Migration[4.2]
  def change
    change_table(:oauth_applications, bulk: true) do |t|
      t.column :owner_id, :integer, null: true
      t.column :owner_type, :string, null: true
    end
    add_index :oauth_applications, [:owner_id, :owner_type]
  end
end
