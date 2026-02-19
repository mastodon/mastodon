# frozen_string_literal: true

class DropEndToEndMessageTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :system_keys
    drop_table :one_time_keys
    drop_table :encrypted_messages
    drop_table :devices
    safety_assured { remove_column :accounts, :devices_url }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
