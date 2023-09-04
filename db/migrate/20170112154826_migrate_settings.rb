class MigrateSettings < ActiveRecord::Migration[4.2]
  def up
    remove_index :settings, [:target_type, :target_id, :var]
    rename_column :settings, :target_id, :thing_id
    rename_column :settings, :target_type, :thing_type
    change_column :settings, :thing_id, :integer, null: true, default: nil
    change_column :settings, :thing_type, :string, null: true, default: nil
    add_index :settings, [:thing_type, :thing_id, :var], unique: true
  end

  def down
    remove_index :settings, [:thing_type, :thing_id, :var]
    rename_column :settings, :thing_id, :target_id
    rename_column :settings, :thing_type, :target_type
    change_column :settings, :target_id, :integer, null: false
    change_column :settings, :target_type, :string, null: false, default: ''
    add_index :settings, [:target_type, :target_id, :var], unique: true
  end
end
