# frozen_string_literal: true

class RemoveOwnerFromApplication < ActiveRecord::Migration[5.0]
  def change
    remove_index :oauth_applications, [:owner_id, :owner_type]
    remove_column :oauth_applications, :owner_id, :integer, null: true
    remove_column :oauth_applications, :owner_type, :string, null: true
  end
end
