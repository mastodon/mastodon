# frozen_string_literal: true

class RemoveDevices < ActiveRecord::Migration[5.0]
  def up
    drop_table :devices if table_exists?(:devices)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
