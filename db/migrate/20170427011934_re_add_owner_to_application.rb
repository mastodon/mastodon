class ReAddOwnerToApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :oauth_applications, :owner_id, :integer, null: true
    add_column :oauth_applications, :owner_type, :string, null: true
    add_index :oauth_applications, [:owner_id, :owner_type]
    add_foreign_key :oauth_applications, :users, column: :owner_id, on_delete: :cascade
  end
end
