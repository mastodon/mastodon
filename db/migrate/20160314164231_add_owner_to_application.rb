class AddOwnerToApplication < ActiveRecord::Migration[4.2]
  def change
    change_table :oauth_applications, bulk: true do |t|
      t.column :owner_id, :integer, null: true
      t.column :owner_type, :string, null: true
      t.index [:owner_id, :owner_type]
    end
  end
end
