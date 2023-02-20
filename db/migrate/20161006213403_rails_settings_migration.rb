MIGRATION_BASE_CLASS = if ActiveRecord::VERSION::MAJOR >= 5
                         ActiveRecord::Migration[5.0]
                       else
                         ActiveRecord::Migration[4.2]
                       end

class RailsSettingsMigration < MIGRATION_BASE_CLASS
  def self.up
    create_table :settings do |t|
      t.string     :var, null: false
      t.text       :value
      t.references :target, null: false, polymorphic: true, index: { name: 'index_settings_on_target_type_and_target_id' }
      t.timestamps null: true
    end
    add_index :settings, [:target_type, :target_id, :var], unique: true
  end

  def self.down
    drop_table :settings
  end
end
