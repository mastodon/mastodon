# frozen_string_literal: true

class RemoveLegacyUserSettingsColumns < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # In normal usage this should not find anything to delete
    # Deletion here is already done in RemoveLegacyUserSettingsData migration
    # and no data like this should be created from app at this point
    # Deleting again out of caution
    connection.execute(<<~SQL.squish)
      DELETE FROM settings
      WHERE
        thing_type IS NOT NULL
        AND thing_id IS NOT NULL
    SQL

    add_index :settings, :var, unique: true, algorithm: :concurrently
    remove_index :settings, [:thing_type, :thing_id, :var], name: :index_settings_on_thing_type_and_thing_id_and_var, unique: true

    safety_assured do
      remove_column :settings, :thing_type, :string
      remove_column :settings, :thing_id, :bigint
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
