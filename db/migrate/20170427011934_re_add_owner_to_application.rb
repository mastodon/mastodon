class ReAddOwnerToApplication < ActiveRecord::Migration[5.0]
  def change
    change_table :oauth_applications, bulk: true do |t|
      t.column :owner_id, :integer, null: true
      t.column :owner_type, :string, null: true
      t.index [:owner_id, :owner_type]
      t.foreign_key :users, column: :owner_id, on_delete: :cascade
    end
  end
end
