# frozen_string_literal: true

class RemoveSettingsThing < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    connection.execute(<<~SQL.squish)
      DELETE FROM settings WHERE thing_type IS NOT NULL and thing_id IS NOT NULL
    SQL

    add_index :settings, :var, unique: true, algorithm: :concurrently
    remove_index :settings, [:thing_type, :thing_id, :var], name: :index_settings_on_thing_type_and_thing_id_and_var, unique: true

    safety_assured do
      remove_column :settings, :thing_type, :string
      remove_column :settings, :thing_id, :bigint
    end
  end
end
